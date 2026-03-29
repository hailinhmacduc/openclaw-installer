# 🤖 OpenClaw Bot - Bộ cài đặt nhanh

Cài đặt bot AI OpenClaw sạch trên bất kỳ thiết bị macOS/Linux nào chỉ với **1 lệnh**.

---

## ⚡ Cài đặt nhanh

### Cách 1: Cài trực tiếp (1 lệnh)

```bash
curl -fsSL https://raw.githubusercontent.com/hailinhmacduc/openclaw-installer/main/install.sh | bash
```

### Cách 2: Clone rồi cài (2 lệnh)

```bash
git clone https://github.com/hailinhmacduc/openclaw-installer.git
bash openclaw-installer/install.sh
```

---

## 📋 Yêu cầu hệ thống

| Yêu cầu | Chi tiết |
|:---|:---|
| **OS** | macOS 12+ hoặc Linux (Ubuntu 20+) |
| **Node.js** | >= 18 ([Tải tại đây](https://nodejs.org/)) |
| **npm** | Đi kèm Node.js |
| **RAM** | Tối thiểu 2GB |

### Cài Node.js nhanh (nếu chưa có)

```bash
# macOS (dùng Homebrew)
brew install node

# Linux (Ubuntu/Debian)
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs
```

---

## 🔧 Thiết lập sau cài đặt

Sau khi chạy script cài đặt, bạn cần làm 3 việc:

### 1. Tạo Telegram Bot

1. Mở Telegram, tìm **@BotFather**
2. Gửi `/newbot`
3. Đặt tên cho bot
4. Copy **bot token** (dạng `123456789:ABCDefGhIjKl...`)

### 2. Lấy API Key cho AI model

1. Truy cập [OpenRouter.ai](https://openrouter.ai)
2. Đăng ký tài khoản (miễn phí)
3. Vào Settings → API Keys → Tạo key mới
4. Copy API key

### 3. Cập nhật config

Mở file config:

```bash
nano ~/.openclaw/openclaw.json
```

Thay các giá trị sau:

| Placeholder | Thay bằng | Lấy ở đâu |
|:---|:---|:---|
| `YOUR_TELEGRAM_BOT_TOKEN` | Token bot Telegram | @BotFather |
| `YOUR_TELEGRAM_USER_ID` | ID Telegram của bạn | @userinfobot |
| `OPENROUTER_API_KEY` | API key OpenRouter | openrouter.ai |

Sau đó bật Telegram:
```json
"telegram": {
  "enabled": true,  // ← đổi từ false thành true
  ...
}
```

Và bật plugin telegram:
```json
"plugins": {
  "entries": {
    "telegram": { "enabled": true }
  }
}
```

---

## 🚀 Khởi động bot

```bash
# Khởi động gateway
openclaw gateway start

# Mở dashboard trên trình duyệt
openclaw gateway open

# Kiểm tra trạng thái
openclaw doctor
```

---

## 🔌 Kênh liên lạc bổ sung (tùy chọn)

### Discord

Thêm vào phần `channels` trong `openclaw.json`:

```json
"discord": {
  "enabled": true,
  "token": "YOUR_DISCORD_BOT_TOKEN",
  "groupPolicy": "open",
  "dmPolicy": "open",
  "allowFrom": ["*"]
}
```

Và bật plugin:
```json
"plugins": { "entries": { "discord": { "enabled": true } } }
```

### Zalo (OpenZalo)

```bash
# Cài plugin
openclaw plugin install openzalo
```

Thêm vào config channels:
```json
"openzalo": {
  "enabled": true,
  "dmPolicy": "allowlist",
  "allowFrom": ["YOUR_ZALO_USER_ID"],
  "groupPolicy": "open"
}
```

Và bật plugin:
```json
"plugins": { "entries": { "openzalo": { "enabled": true } } }
```

---

## 📁 Cấu trúc thư mục

```
~/.openclaw/              ← State & config chính
├── openclaw.json         ← File cấu hình
├── memory/               ← Bộ nhớ bot (tự tạo)
├── skills/               ← Skills đã cài
├── extensions/           ← Plugins
└── logs/                 ← Log files

~/openclaw-workspace/     ← Workspace thư mục làm việc
```

---

## 🛠 Skills có sẵn

| Skill | Mô tả |
|:---|:---|
| **coding-agent** | Hỗ trợ viết code, debug |
| **web search** | Tìm kiếm thông tin trên web |
| **web fetch** | Đọc nội dung trang web |
| **session-memory** | Ghi nhớ ngữ cảnh hội thoại |

---

## ❓ Xử lý lỗi thường gặp

### Bot không phản hồi trên Telegram
- Kiểm tra bot token đúng chưa
- Kiểm tra `enabled: true` trong config
- Chạy `openclaw doctor` để kiểm tra

### Không kết nối được AI model
- Kiểm tra API key OpenRouter
- Thử đổi model khác trong config
- Kiểm tra kết nối internet

### Port đã bị sử dụng
- Đổi port trong config: `"gateway": { "port": 18790 }`
- Hoặc tắt process đang dùng port cũ

---

## 📄 License

MIT License - Tự do sử dụng và phân phối.
