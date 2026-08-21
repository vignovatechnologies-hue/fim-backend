import datetime
from fastapi import APIRouter, Depends, HTTPException, Body
from fastapi.responses import JSONResponse
from sqlalchemy.orm import Session
from typing import Optional

from database import get_db
from models import Transaction, Budget, User
from schemas import TransactionCreate, TransactionResponse, BudgetCategoryResponse
from dependencies import get_current_user

router = APIRouter(tags=["transactions"])

BUDGET_COLORS = {
    "Food & Dining":   "bg-amber-100 text-amber-700",
    "Shopping":        "bg-rose-100 text-rose-700",
    "Transport":       "bg-sky-100 text-sky-700",
    "Entertainment":   "bg-violet-100 text-violet-700",
    "Home & Bills":    "bg-emerald-100 text-emerald-700",
}

CAT_MAP = {
    "Food":          "Food & Dining",
    "Shopping":      "Shopping",
    "Transport":     "Transport",
    "Entertainment": "Entertainment",
    "Home":          "Home & Bills",
    "Bills":         "Home & Bills",
    "Healthcare":    "Shopping",
    "Income":        "Income",
    "Salary":        "Income",
    "Freelance":     "Income",
    "Investments":   "Income",
    "Gift":          "Income",
    "Other Income":  "Income",
    "Savings":       "Savings",
}

INCOME_CATEGORIES = {"Income", "Salary", "Freelance", "Investments", "Gift", "Other Income"}

def _serialize_txn(txn) -> dict:
    return TransactionResponse.from_orm_model(txn).model_dump()


@router.get("/api/transactions")
def get_transactions(
    month: Optional[int] = None,
    year: Optional[int] = None,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    query = db.query(Transaction).filter(Transaction.user_id == current_user.id)
    if month is not None and year is not None:
        start_of_month = datetime.datetime(year, month, 1)
        if month == 12:
            end_of_month = datetime.datetime(year + 1, 1, 1)
        else:
            end_of_month = datetime.datetime(year, month + 1, 1)
        query = query.filter(Transaction.when >= start_of_month, Transaction.when < end_of_month)
        
    txns = query.order_by(Transaction.when.desc()).limit(100).all()
    return JSONResponse([_serialize_txn(t) for t in txns])


# ── ADD a transaction (expense / income) ──────────────────────────────────────
@router.post("/api/transactions")
def add_transaction(
    txn_data: TransactionCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    raw_cat = txn_data.category.strip()
    std_cat = CAT_MAP.get(raw_cat, raw_cat)
    
    # ── Strict Income vs Expense determination ─────────────────────────────
    is_income = (
        (txn_data.payment_status and txn_data.payment_status.lower() == "credit")
        or raw_cat in INCOME_CATEGORIES
        or std_cat == "Income"
        or (txn_data.amount > 0 and (not txn_data.payment_status or txn_data.payment_status.lower() != "debit"))
    )

    if is_income:
        final_amount = abs(txn_data.amount)
        payment_status = "credit"
        final_category = raw_cat if raw_cat in INCOME_CATEGORIES else "Income"
    else:
        final_amount = -abs(txn_data.amount)
        payment_status = "debit"
        final_category = std_cat if std_cat in CAT_MAP.values() else raw_cat

    txn = Transaction(
        user_id=current_user.id,
        name=txn_data.name.strip(),
        category=final_category,
        amount=final_amount,
        payment_status=payment_status,
        when=datetime.datetime.utcnow(),
    )
    db.add(txn)
    db.commit()
    db.refresh(txn)
    return JSONResponse(_serialize_txn(txn))


# ── DELETE a transaction ──────────────────────────────────────────────────────
@router.delete("/api/transactions/{txn_id}")
def delete_transaction(
    txn_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    txn = db.query(Transaction).filter(
        Transaction.id == txn_id,
        Transaction.user_id == current_user.id
    ).first()
    if not txn:
        raise HTTPException(status_code=404, detail="Transaction not found")

    db.delete(txn)
    db.commit()
    return JSONResponse({"status": "success", "message": "Transaction deleted successfully", "id": txn_id})


# ── GET budgets with real spent amounts ───────────────────────────────────────
@router.get("/api/budgets")
def get_budgets(
    month: Optional[int] = None,
    year: Optional[int] = None,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    budgets = db.query(Budget).filter(Budget.user_id == current_user.id).all()

    now = datetime.datetime.utcnow()
    m = month if month is not None else now.month
    y = year if year is not None else now.year

    start_of_month = datetime.datetime(y, m, 1)
    if m == 12:
        end_of_month = datetime.datetime(y + 1, 1, 1)
    else:
        end_of_month = datetime.datetime(y, m + 1, 1)

    result = []
    for b in budgets:
        spent = (
            db.query(Transaction)
            .filter(
                Transaction.user_id == current_user.id,
                Transaction.category == b.category,
                Transaction.when >= start_of_month,
                Transaction.when < end_of_month,
                Transaction.amount < 0,
            )
            .all()
        )
        total_spent = sum(abs(t.amount) for t in spent)
        result.append({
            "name":   b.category,
            "spent":  round(total_spent, 2),
            "budget": round(b.budget_amount, 2),
            "color":  BUDGET_COLORS.get(b.category, "bg-gray-100 text-gray-700"),
        })

    return JSONResponse(result)


# ── POST /api/budgets to update user budgets ─────────────────────────────────
@router.post("/api/budgets")
def update_user_budgets(
    payload: dict = Body(...),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    for category, amount in payload.items():
        budget = db.query(Budget).filter(
            Budget.user_id == current_user.id,
            Budget.category == category
        ).first()
        
        if budget:
            budget.budget_amount = float(amount)
        else:
            new_budget = Budget(
                user_id=current_user.id,
                category=category,
                budget_amount=float(amount)
            )
            db.add(new_budget)
            
    db.commit()
    return JSONResponse({"status": "success", "message": "Budgets updated successfully"})
