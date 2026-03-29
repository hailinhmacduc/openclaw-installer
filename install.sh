#!/bin/bash
set -e

# ============================================================
#  OpenClaw Bot - Bộ cài đặt nhanh
#  Cài đặt bot AI sạch với 1 lệnh
# ============================================================

BOLD='\033[1m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

STATE_DIR="$HOME/.openclaw"
WORKSPACE="$HOME/openclaw-workspace"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_URL="https://raw.githubusercontent.com/hailinhmacduc/openclaw-installer/main"

echo ""
echo -e "${CYAN}${BOLD}╔══════════════════════════════════════════╗${NC}"
echo -e "${CYAN}${BOLD}║   🤖 OpenClaw Bot - Cài đặt nhanh       ║${NC}"
echo -e "${CYAN}${BOLD}╚══════════════════════════════════════════╝${NC}"
echo ""

# ─── Bước 0: Kiểm tra xung đột ───────────────────────────
if [ -d "$STATE_DIR" ]; then
  echo -e "${YELLOW}⚠️  Phát hiện thư mục $STATE_DIR đã tồn tại.${NC}"
  echo -e "   Bạn đã có OpenClaw trên máy này."
  echo ""
  read -p "Bạn muốn tạo profile MỚI tách biệt? (y/n): " CHOICE
  if [ "$CHOICE" = "y" ] || [ "$CHOICE" = "Y" ]; then
    read -p "Nhập tên profile (vd: sale, demo, client1): " PROFILE_NAME
    if [ -z "$PROFILE_NAME" ]; then
      echo -e "${RED}❌ Tên profile không được trống.${NC}"
      exit 1
    fi
    STATE_DIR="$HOME/.openclaw-${PROFILE_NAME}"
    WORKSPACE="$HOME/openclaw-workspace-${PROFILE_NAME}"
    echo -e "${GREEN}✅ Sẽ cài vào: $STATE_DIR${NC}"
  else
    echo -e "${RED}❌ Đã hủy cài đặt.${NC}"
    exit 0
  fi
fi

# ─── Bước 1: Kiểm tra Node.js ─────────────────────────────
echo -e "${BOLD}[1/5] Kiểm tra Node.js...${NC}"
if ! command -v node &> /dev/null; then
  echo -e "${RED}❌ Chưa cài Node.js!${NC}"
  echo "   Vui lòng cài Node.js >= 18: https://nodejs.org/"
  echo "   Hoặc dùng Homebrew: brew install node"
  exit 1
fi

NODE_VER=$(node -v | sed 's/v//' | cut -d. -f1)
if [ "$NODE_VER" -lt 18 ]; then
  echo -e "${RED}❌ Node.js phiên bản $NODE_VER quá cũ. Cần >= 18.${NC}"
  exit 1
fi
echo -e "   ✅ Node.js $(node -v)"

# ─── Bước 2: Cài OpenClaw CLI ─────────────────────────────
echo -e "${BOLD}[2/5] Cài đặt OpenClaw CLI...${NC}"
if command -v openclaw &> /dev/null; then
  echo -e "   ✅ OpenClaw CLI đã có sẵn ($(openclaw --version 2>/dev/null || echo 'installed'))"
else
  echo "   Đang cài openclaw qua npm..."
  npm install -g openclaw
  echo -e "   ✅ OpenClaw CLI đã cài xong"
fi

# ─── Bước 3: Tạo thư mục state và workspace ───────────────
echo -e "${BOLD}[3/5] Tạo thư mục...${NC}"
mkdir -p "$STATE_DIR"
mkdir -p "$WORKSPACE"
echo -e "   ✅ State dir: $STATE_DIR"
echo -e "   ✅ Workspace: $WORKSPACE"

# ─── Bước 4: Copy config template ─────────────────────────
echo -e "${BOLD}[4/5] Cài đặt cấu hình...${NC}"

# Tìm file config template
CONFIG_SRC=""
if [ -f "$SCRIPT_DIR/openclaw-clean.json" ]; then
  CONFIG_SRC="$SCRIPT_DIR/openclaw-clean.json"
fi

# Nếu không có local, tải từ GitHub
if [ -z "$CONFIG_SRC" ]; then
  echo "   Đang tải config template từ GitHub..."
  curl -fsSL "$REPO_URL/openclaw-clean.json" -o "/tmp/openclaw-clean.json"
  CONFIG_SRC="/tmp/openclaw-clean.json"
fi

# Thay workspace path và copy
if command -v python3 &> /dev/null; then
  python3 -c "
import json
with open('$CONFIG_SRC', 'r') as f:
    config = json.load(f)
for agent in config.get('agents', {}).get('list', []):
    if agent.get('workspace') == 'WORKSPACE_PATH_PLACEHOLDER':
        agent['workspace'] = '$WORKSPACE'
with open('$STATE_DIR/openclaw.json', 'w') as f:
    json.dump(config, f, indent=2, ensure_ascii=False)
"
  echo -e "   ✅ Config đã cài vào $STATE_DIR/openclaw.json"
else
  cp "$CONFIG_SRC" "$STATE_DIR/openclaw.json"
  sed -i '' "s|WORKSPACE_PATH_PLACEHOLDER|$WORKSPACE|g" "$STATE_DIR/openclaw.json" 2>/dev/null || \
  sed -i "s|WORKSPACE_PATH_PLACEHOLDER|$WORKSPACE|g" "$STATE_DIR/openclaw.json" 2>/dev/null || true
  echo -e "   ✅ Config đã cài"
fi

# Cleanup
[ -f "/tmp/openclaw-clean.json" ] && rm -f "/tmp/openclaw-clean.json"

# ─── Bước 5: Thông báo plugins ────────────────────────────
echo -e "${BOLD}[5/5] Plugins sẵn sàng...${NC}"
echo -e "   ✅ Plugin OpenZalo có thể cài bằng: openclaw plugin install openzalo"

# ─── Hoàn tất ─────────────────────────────────────────────
echo ""
echo -e "${GREEN}${BOLD}╔══════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}${BOLD}║   ✅ CÀI ĐẶT HOÀN TẤT!                             ║${NC}"
echo -e "${GREEN}${BOLD}╚══════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BOLD}📁 Thư mục:${NC}"
echo -e "   State:     $STATE_DIR"
echo -e "   Workspace: $WORKSPACE"
echo -e "   Config:    $STATE_DIR/openclaw.json"
echo ""
echo -e "${BOLD}📋 Hướng dẫn tiếp theo:${NC}"
echo ""
echo -e "   ${CYAN}1. Thiết lập Telegram Bot:${NC}"
echo -e "      • Mở Telegram, tìm @BotFather"
echo -e "      • Gửi /newbot và làm theo hướng dẫn"
echo -e "      • Copy bot token"
echo ""
echo -e "   ${CYAN}2. Thiết lập API Key (model AI):${NC}"
echo -e "      • Đăng ký tại https://openrouter.ai"
echo -e "      • Tạo API key miễn phí"
echo ""
echo -e "   ${CYAN}3. Cập nhật config:${NC}"
echo -e "      Mở file config và điền thông tin:"
echo ""

if [ "$STATE_DIR" != "$HOME/.openclaw" ]; then
  PROFILE_FLAG="--profile $(basename $STATE_DIR | sed 's/\.openclaw-//')"
  echo -e "      ${YELLOW}nano $STATE_DIR/openclaw.json${NC}"
  echo ""
  echo -e "      Thay các giá trị:"
  echo -e "      • YOUR_TELEGRAM_BOT_TOKEN  → Bot token từ @BotFather"
  echo -e "      • YOUR_TELEGRAM_USER_ID    → Telegram user ID của bạn"
  echo -e "      • OPENROUTER_API_KEY       → API key từ OpenRouter"
  echo ""
  echo -e "   ${CYAN}4. Khởi động bot:${NC}"
  echo -e "      ${YELLOW}openclaw $PROFILE_FLAG gateway start${NC}"
  echo ""
  echo -e "   ${CYAN}5. Mở Dashboard:${NC}"
  echo -e "      ${YELLOW}openclaw $PROFILE_FLAG gateway open${NC}"
else
  echo -e "      ${YELLOW}nano $STATE_DIR/openclaw.json${NC}"
  echo ""
  echo -e "      Thay các giá trị:"
  echo -e "      • YOUR_TELEGRAM_BOT_TOKEN  → Bot token từ @BotFather"
  echo -e "      • YOUR_TELEGRAM_USER_ID    → Telegram user ID của bạn"
  echo -e "      • OPENROUTER_API_KEY       → API key từ OpenRouter"
  echo ""
  echo -e "   ${CYAN}4. Khởi động bot:${NC}"
  echo -e "      ${YELLOW}openclaw gateway start${NC}"
  echo ""
  echo -e "   ${CYAN}5. Mở Dashboard:${NC}"
  echo -e "      ${YELLOW}openclaw gateway open${NC}"
fi

echo ""
echo -e "${BOLD}🔌 Kênh liên lạc (tùy chọn thêm):${NC}"
echo -e "   • Discord:  Thêm config discord vào channels trong openclaw.json"
echo -e "   • Zalo:     Chạy: openclaw plugin install openzalo"
echo ""
echo -e "${GREEN}Chúc bạn sử dụng vui vẻ! 🚀${NC}"
echo ""
