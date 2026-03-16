# وثيقة المواصفات التقنية للخلفية البرمجية (Backend Specification)
## نظام المزايدات الحية (Live Auction System)

توضح هذه الوثيقة المتطلبات اللازمة من جانب الـ Backend لدعم تطبيق Flutter الذي تم بناؤه، وتشمل هيكلية قاعدة البيانات، روابط الـ API، والربط الحي عبر Sockets.

---

## 1. هيكلية قاعدة البيانات (Database Schema)

### جداول قاعدة البيانات والعلاقات:

#### 1. جدول المستخدمين (Users)
- `id` (UUID): معرف فريد.
- `full_name` (String): الاسم الكامل.
- `email` (String): البريد الإلكتروني (Unique).
- `password_hash` (String): كلمة المرور المشفرة.
- `avatar_url` (String): رابط صورة المستخدم.
- `balance` (Decimal): الرصيد الحالي بالمحفظة.
- `fcm_token` (String): للاشعارات اللحظية.
- `total_wins` (Integer): عدد المزادات التي ربحها.
- `rating` (Float): تقييم المستخدم كبائع.

#### 2. جدول الفئات (Categories)
- `id` (Integer).
- `name` (String): اسم الفئة (ساعات، سيارات، إلكترونيات).
- `icon_url` (String).

#### 3. جدول المزادات (Auctions)
- `id` (UUID).
- `title` (String): عنوان المزاد.
- `description` (Text): وصف المنتج.
- `category_id` (FK): يربط بجدول الفئات.
- `seller_id` (FK): يربط بجدول المستخدمين (المالك).
- `initial_price` (Decimal): السعر الابتدائي.
- `current_bid` (Decimal): أعلى سعر وصلنا له حالياً.
- `highest_bidder_id` (FK): يربط بالمستخدم صاحب أعلى مزايدة.
- `start_time` (DateTime): وقت بدء المزاد.
- `end_time` (DateTime): وقت انتهاء المزاد.
- `status` (Enum): (scheduled, live, ended, cancelled).
- `images` (Array of Strings): روابط صور المنتج.

#### 4. جدول المزايدات (Bids)
- `id` (UUID).
- `auction_id` (FK): يربط بالمزاد.
- `user_id` (FK): يربط بالمستخدم المزايد.
- `amount` (Decimal): قيمة المزايدة.
- `timestamp` (DateTime).

#### 5. جدول المحفظة والعمليات (Transactions)
- `id` (UUID).
- `user_id` (FK).
- `amount` (Decimal): (موجب للايداع، سالب للسحب/المزايدة).
- `type` (Enum): (deposit, withdrawal, bid_hold, bid_refund, winning_payment).
- `status` (Enum): (pending, completed, failed).
- `created_at` (DateTime).

#### 6. جدول الاشعارات (Notifications)
- `id` (UUID).
- `user_id` (FK).
- `title` (String).
- `message` (String).
- `type` (Enum): (outbid, ending_soon, won, news).
- `is_read` (Boolean).

---

## 2. روابط الـ API المطلوبة (Restful Endpoints)

### أ. المزادات (Auctions)
1. **GET `/api/auctions`**
   - **الوظيفة**: جلب قائمة المزادات.
   - **الفلاتر**: `status`, `category_id`, `search_query`, `sort_by`.
   - **الرد (Response)**: قائمة من كائنات `Auction` شاملة السعر الحالي والوقت المتبقي.

2. **GET `/api/auctions/{id}`**
   - **الوظيفة**: جلب تفاصيل مزاد محدد بجميع بيانات البائع وتاريخ المزايدات.

3. **POST `/api/auctions/{id}/bid`**
   - **الوظيفة**: تقديم مزايدة جديدة.
   - **الجسم (Body)**: `{ "amount": 5500.0 }`.
   - **الشروط**: يجب أن يكون المبلغ أكبر من `current_bid` ويجب التأكد من وجود رصيد كافٍ في محفظة المستخدم (Booking Amount).

### ب. المحفظة (Wallet)
1. **GET `/api/wallet/balance`**
   - **الرد**: `{ "balance": 2450.50 }`.

2. **GET `/api/wallet/transactions`**
   - **الوظيفة**: عرض كافة العمليات المالية (الايداع، السحب، المزايدات).

3. **POST `/api/wallet/deposit`**
   - **الجسم**: `{ "amount": 1000, "payment_method": "stripe/card" }`.

### ج. المراقبة والاشعارات (Watchlist & Notifications)
1. **GET `/api/watchlist`**: جلب المزادات التي يتابعها المستخدم.
2. **POST `/api/watchlist/{id}`**: إضافة/حذف من قائمة المتابعة.
3. **GET `/api/notifications`**: جلب الاشعارات مع حالة القراءة.
4. **PUT `/api/notifications/read`**: تحديث حالة الاشعارات لتصبح "مقروءة".

### د. المتصدرين (Leaderboard)
1. **GET `/api/leaderboard`**
   - **الرد**: قائمة بالمستخدمين مرتبة حسب `score` أو `wins`.

---

## 3. الربط الحي (Real-time WebSockets)

يتم استخدام **Socket.io** لتحديث الشاشات لحظياً دون الحاجة لإعادة التحميل:

- **الأحداث الصادرة من الـ Backend (Emit):**
  - `bid_updated`: عند قيام أي مستخدم بتقديم مزايدة (يرسل id المزاد، السعر الجديد، ومعلومات المزايد).
  - `auction_status_changed`: عند بدء المزاد أو انتهاء وقته.
  - `new_notification`: تنبيه المستخدم فوراً عند تخطي مزايدته (Outbid).

---

## 4. ملاحظات هامة للمطور:
1. جودة البيانات: يجب أن تكون الصور بروابط مباشرة تعمل على الويب والموبايل.
2. التوقيت: يجب ارسال جميع التواريخ بتنسيق **ISO 8601** (UTC).
3. الحماية: استخدام **JWT Token** في الـ Headers لجميع الروابط المحمية.
4. المحفظة: المزايدة يجب أن تقوم بـ "حجز" المبلغ من المحفظة مؤقتاً، وفي حال قام شخص آخر بمزايدة أعلى، يتم "فك الحجز" وإرجاع المبلغ للمستخدم الأصلي فوراً.

---
**تم إعداد هذه الوثيقة لتتوافق مع شاشات تطبيق Flutter Dashboard التي تم تنفيذها.**
