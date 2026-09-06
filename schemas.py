from pydantic import BaseModel, EmailStr, Field
from typing import Optional, List
from datetime import datetime

# Auth Token Schemas
class Token(BaseModel):
    access_token: str
    token_type: str

class TokenData(BaseModel):
    email: Optional[str] = None

# User Schemas
class UserCreate(BaseModel):
    name: str
    email: EmailStr
    password: str
    phone: Optional[str] = None

class UserLogin(BaseModel):
    email: EmailStr
    password: str

class UserResponse(BaseModel):
    id: int
    email: str
    name: str
    phone: Optional[str] = None
    initials: str
    verified: bool
    premium: bool
    reminders_enabled: bool = True
    photo_data: Optional[str] = None

    class Config:
        from_attributes = True

class UserVerify(BaseModel):
    email: EmailStr
    code: str

class UserResetRequest(BaseModel):
    email: EmailStr

class UserResetSubmit(BaseModel):
    email: EmailStr
    code: str
    new_password: str

# Loan Schemas
class LoanCreate(BaseModel):
    name: str
    type: str  # Home, Personal, Auto, Education, Consumer
    emi: float
    rate: float
    due_day: Optional[int] = 15
    start_date: Optional[datetime] = None
    end_date: Optional[datetime] = None
    left_amount: Optional[float] = None
    original_amount: Optional[float] = None
    total_tenure: Optional[int] = None
    paid_tenure: Optional[int] = None

class LoanUpdate(BaseModel):
    name: Optional[str] = None
    type: Optional[str] = None
    emi: Optional[float] = None
    rate: Optional[float] = None
    due_day: Optional[int] = None
    start_date: Optional[datetime] = None
    end_date: Optional[datetime] = None
    left_amount: Optional[float] = None
    original_amount: Optional[float] = None
    total_tenure: Optional[int] = None
    paid_tenure: Optional[int] = None

class LoanResponse(BaseModel):
    id: int
    name: str
    type: str
    emi: float
    left: float
    left_amount: float
    original_amount: Optional[float] = None
    tenure: str
    total_tenure: int
    paid_tenure: int
    rate: float
    due: int
    due_day: int
    logo: str
    paid: bool
    paid_this_month: bool
    start_date: Optional[str] = None
    end_date: Optional[str] = None

    class Config:
        from_attributes = True

    @classmethod
    def from_orm_model(cls, loan):
        tenure_str = f"{loan.paid_tenure}/{loan.total_tenure}"
        return cls(
            id=loan.id,
            name=loan.name,
            type=loan.type,
            emi=loan.emi,
            left=loan.left_amount,
            left_amount=loan.left_amount,
            original_amount=loan.original_amount,
            tenure=tenure_str,
            total_tenure=loan.total_tenure or 24,
            paid_tenure=loan.paid_tenure or 0,
            rate=loan.rate,
            due=loan.due_day,
            due_day=loan.due_day,
            logo=loan.logo,
            paid=loan.paid_this_month,
            paid_this_month=loan.paid_this_month,
            start_date=loan.start_date.isoformat() if loan.start_date else None,
            end_date=loan.end_date.isoformat() if loan.end_date else None
        )

# Transaction Schemas
class TransactionCreate(BaseModel):
    name: str
    category: str
    amount: float
    payment_status: Optional[str] = None
    when: Optional[str] = None

class TransactionResponse(BaseModel):
    id: int
    name: str
    category: str
    amount: float
    payment_status: str
    when: str

    class Config:
        from_attributes = True

    @classmethod
    def from_orm_model(cls, txn):
        status = txn.payment_status or ("credit" if txn.amount > 0 else "debit")
        when_iso = txn.when.isoformat() if txn.when else datetime.utcnow().isoformat()
        return cls(
            id=txn.id,
            name=txn.name,
            category=txn.category,
            amount=txn.amount,
            payment_status=status,
            when=when_iso
        )

# Budget Schemas
class BudgetCategoryResponse(BaseModel):
    name: str
    spent: float
    budget: float
    color: str

# Savings Goal Schemas
class SavingsGoalCreate(BaseModel):
    name: str
    target: float = Field(..., alias="target_amount")

    class Config:
        populate_by_name = True

class SavingsGoalResponse(BaseModel):
    id: int
    name: str
    saved: float = Field(..., alias="saved_amount")
    target: float = Field(..., alias="target_amount")
    eta: Optional[str] = "—"
    color: Optional[str] = "bg-emerald-100 text-emerald-700"

    class Config:
        from_attributes = True
        populate_by_name = True

# Savings Goal Contribution
class SavingsGoalContribution(BaseModel):
    amount: float


# Bank Schemas
class BankCreate(BaseModel):
    name: str
    account_number: str
    ifsc_code: str

class BankResponse(BaseModel):
    id: int
    name: str
    masked: str = Field(..., alias="masked_acc")
    ifsc_code: Optional[str] = None

    class Config:
        from_attributes = True
        populate_by_name = True

# Dashboard Summary Schema
class DashboardSummary(BaseModel):
    net_balance: float
    income: float
    spent: float
    active_loans_count: int
    outstanding_loans_amount: float
    health_score: int
    savings_goal_percent: float
    savings_goal_text: str
    next_emi_days: str
    next_emi_name: str
    
    # Flutter compatibility fields
    total_balance: Optional[float] = 0.0
    monthly_income: Optional[float] = 0.0
    monthly_expense: Optional[float] = 0.0
    monthly_emi_total: Optional[float] = 0.0
    total_debt: Optional[float] = 0.0
    total_savings: Optional[float] = 0.0
    recent_transactions: Optional[List[dict]] = []
    upcoming_emis: Optional[List[dict]] = []
    savings_goals: Optional[List[dict]] = []

class FCMTokenRegister(BaseModel):
    fcm_token: str
