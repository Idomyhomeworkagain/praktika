# database.py - работа с SQLite базой данных

from sqlalchemy import create_engine, Column, Integer, String, Boolean, DateTime, JSON, ForeignKey
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, relationship
from datetime import datetime
import json

DATABASE_URL = "sqlite:///./chess.db"
engine = create_engine(DATABASE_URL, connect_args={"check_same_thread": False})
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# ========== МОДЕЛИ ТАБЛИЦ ==========

class User(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, unique=True, index=True)
    email = Column(String, unique=True, index=True)
    elo = Column(Integer, default=1200)
    streak_days = Column(Integer, default=0)
    created_at = Column(DateTime, default=datetime.utcnow)
    
    stats = relationship("UserStats", back_populates="user", uselist=False)
    progress = relationship("UserProgress", back_populates="user")
    games = relationship("GameHistory", back_populates="user")

class UserStats(Base):
    __tablename__ = "user_stats"
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    games_played = Column(Integer, default=0)
    wins = Column(Integer, default=0)
    losses = Column(Integer, default=0)
    draws = Column(Integer, default=0)
    total_games = Column(Integer, default=0)
    
    user = relationship("User", back_populates="stats")

class UserProgress(Base):
    __tablename__ = "user_progress"
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    level_id = Column(Integer)
    stars = Column(Integer, default=0)
    
    user = relationship("User", back_populates="progress")

class GameHistory(Base):
    __tablename__ = "game_history"
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    result = Column(String)
    bot_level = Column(Integer)
    moves_count = Column(Integer)
    fen_history = Column(String)
    played_at = Column(DateTime, default=datetime.utcnow)
    
    user = relationship("User", back_populates="games")

# === НАША ТАБЛИЦА ДЛЯ УРОКОВ И ЗАДАЧ ===
class Task(Base):
    __tablename__ = "tasks"
    id = Column(Integer, primary_key=True, index=True)
    title = Column(String)
    category = Column(String)
    description = Column(String)
    fen = Column(String)
    solution = Column(String)
    type = Column(String, default="puzzle") # "lesson" или "puzzle"

# ========== ФУНКЦИИ БАЗЫ ДАННЫХ ==========

def init_db():
    Base.metadata.create_all(bind=engine)
    db = SessionLocal()
    # Создаем базового юзера, если его нет
    if not db.query(User).first():
        user = User(username="Player1", email="test@test.com")
        db.add(user)
        db.commit()
        db.refresh(user)
        stats = UserStats(user_id=user.id)
        db.add(stats)
        db.commit()
    db.close()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

def get_user_profile(db, user_id: int):
    user = db.query(User).filter(User.id == user_id).first()
    stats = db.query(UserStats).filter(UserStats.user_id == user_id).first()
    if not user:
        return None
    return {
        "username": user.username,
        "elo": user.elo,
        "streak_days": user.streak_days,
        "wins": stats.wins if stats else 0,
        "losses": stats.losses if stats else 0,
        "draws": stats.draws if stats else 0,
        "total_games": stats.total_games if stats else 0
    }

def get_user_progress(db, user_id: int):
    return db.query(UserProgress).filter(UserProgress.user_id == user_id).all()

def update_user_stats(db, user_id: int, result: str, bot_level: int, moves_count: int):
    stats = db.query(UserStats).filter(UserStats.user_id == user_id).first()
    if not stats:
        stats = UserStats(user_id=user_id)
        db.add(stats)
    
    if result == "win":
        stats.wins += 1
        user = db.query(User).filter(User.id == user_id).first()
        if user: user.elo += 10
    elif result == "loss":
        stats.losses += 1
        user = db.query(User).filter(User.id == user_id).first()
        if user: user.elo = max(800, user.elo - 10)
    else:
        stats.draws += 1
        
    stats.total_games += 1
    
    game = GameHistory(user_id=user_id, result=result, bot_level=bot_level, moves_count=moves_count, fen_history="[]")
    db.add(game)
    db.commit()

def complete_level(db, user_id: int, level_id: int, stars: int):
    progress = db.query(UserProgress).filter(UserProgress.user_id == user_id, UserProgress.level_id == level_id).first()
    if progress:
        if stars > progress.stars:
            progress.stars = stars
    else:
        progress = UserProgress(user_id=user_id, level_id=level_id, stars=stars)
        db.add(progress)
    db.commit()