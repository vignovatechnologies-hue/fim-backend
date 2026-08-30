import datetime
from fastapi import APIRouter, Depends
from fastapi.responses import JSONResponse
from sqlalchemy.orm import Session
from sqlalchemy import or_

from database import get_db
from models import Transaction, Loan, SavingsGoal, User
from schemas import DashboardSummary, TransactionResponse, LoanResponse, SavingsGoalResponse
from dependencies import get_current_user

router = APIRouter(tags=["dashboard"])

@router.get("/api/dashboard/summary")
def get_dashboard_summary(current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    now = datetime.datetime.utcnow()
    start_of_month = datetime.datetime(now.year, now.month, 1)

    # Monthly Income & Expenses
    income_txns = db.query(Transaction).filter(
        Transaction.user_id == current_user.id,
        or_(Transaction.amount > 0, Transaction.payment_status == "credit", Transaction.category == "Income"),
        Transaction.when >= start_of_month
    ).all()
    income = sum([abs(t.amount) for t in income_txns])

    spent_txns = db.query(Transaction).filter(
        Transaction.user_id == current_user.id,
        or_(Transaction.amount < 0, Transaction.payment_status == "debit"),
        Transaction.when >= start_of_month
    ).all()
    spent = sum([abs(t.amount) for t in spent_txns])

    # All time income & expenses for Net Portfolio Balance
    all_income = sum([abs(t.amount) for t in db.query(Transaction).filter(
        Transaction.user_id == current_user.id,
        or_(Transaction.amount > 0, Transaction.payment_status == "credit", Transaction.category == "Income")
    ).all()])

    all_spent = sum([abs(t.amount) for t in db.query(Transaction).filter(
        Transaction.user_id == current_user.id,
        or_(Transaction.amount < 0, Transaction.payment_status == "debit")
    ).all()])

    net_balance = all_income - all_spent

    # Loans
    loans = db.query(Loan).filter(Loan.user_id == current_user.id).all()
    active_loans_count = len(loans)
    outstanding_loans_amount = sum([l.left_amount for l in loans])
    monthly_emi_total = sum([l.emi for l in loans if not l.paid_this_month])

    next_emi_days = "—"
    next_emi_name = "No upcoming EMIs"
    unpaid_loans = [l for l in loans if not l.paid_this_month]
    if unpaid_loans:
        unpaid_loans.sort(key=lambda x: x.due_day)
        next_loan = unpaid_loans[0]
        days_left = next_loan.due_day - now.day
        if days_left < 0:
            import calendar
            days_in_month = calendar.monthrange(now.year, now.month)[1]
            days_left = (days_in_month - now.day) + next_loan.due_day
            
        next_emi_days = f"{days_left}d"
        next_emi_name = next_loan.name

    # Savings
    goals = db.query(SavingsGoal).filter(SavingsGoal.user_id == current_user.id).all()
    total_target = sum([g.target_amount for g in goals])
    total_saved = sum([g.saved_amount for g in goals])
    
    savings_goal_percent = 0.0
    if total_target > 0:
        savings_goal_percent = round((total_saved / total_target) * 100)
        
    savings_goal_text = f"₹ {round(total_saved/1000)}k of {round(total_target/1000)}k"
    if total_saved >= 100000:
        savings_goal_text = f"₹ {round(total_saved/100000, 1)}L of {round(total_target/100000, 1)}L"

    # Health Score Calculation
    health_score = 75
    if income > 0:
        spend_ratio = spent / income
        if spend_ratio < 0.5:
            health_score += 10
        elif spend_ratio > 0.8:
            health_score -= 10
            
        total_monthly_emi = sum([l.emi for l in loans])
        debt_ratio = total_monthly_emi / income
        if debt_ratio > 0.4:
            health_score -= 10
        elif debt_ratio < 0.2:
            health_score += 5
            
    health_score = max(10, min(100, health_score))

    # Recent 10 Transactions for Overview Activity List
    recent_transactions = []
    try:
        recent_txns_orm = db.query(Transaction).filter(
            Transaction.user_id == current_user.id
        ).order_by(Transaction.when.desc()).limit(10).all()
        recent_transactions = [TransactionResponse.from_orm_model(t).model_dump() for t in recent_txns_orm]
    except Exception as e:
        print(f"[dashboard] ⚠️ Error mapping recent_transactions: {e}")

    # Upcoming EMIs for Overview List
    upcoming_emis_list = []
    try:
        upcoming_emis_list = [LoanResponse.from_orm_model(l).model_dump() for l in unpaid_loans]
    except Exception as e:
        print(f"[dashboard] ⚠️ Error mapping upcoming_emis: {e}")

    # Savings Goals for Overview List
    savings_goals_list = []
    try:
        savings_goals_list = [SavingsGoalResponse.from_orm_model(g).model_dump() for g in goals]
    except Exception as e:
        print(f"[dashboard] ⚠️ Error mapping savings_goals: {e}")

    summary = DashboardSummary(
        net_balance=net_balance,
        income=income,
        spent=spent,
        active_loans_count=active_loans_count,
        outstanding_loans_amount=outstanding_loans_amount,
        health_score=health_score,
        savings_goal_percent=savings_goal_percent,
        savings_goal_text=savings_goal_text,
        next_emi_days=next_emi_days,
        next_emi_name=next_emi_name,
        
        total_balance=net_balance,
        monthly_income=income,
        monthly_expense=spent,
        monthly_emi_total=monthly_emi_total,
        total_debt=outstanding_loans_amount,
        total_savings=total_saved,
        recent_transactions=recent_transactions,
        upcoming_emis=upcoming_emis_list,
        savings_goals=savings_goals_list,
    )
    return JSONResponse(summary.model_dump())
