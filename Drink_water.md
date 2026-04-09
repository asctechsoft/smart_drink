**Mô tả ứng dụng Drink water**

1. **Luồng onboarding**

### **0\) Splash / Khởi động**

* **Mục đích:** Màn hình thương hiệu/loading khi mở app.

* **UI:** Icon app \+ chữ “DRINK WATER” trên nền xanh nhạt.

* **Điều hướng:** Tự động chuyển sang màn Chào mừng sau vài giây.

### **1\) Chào mừng / Giới thiệu**

* **UI:** Hình giọt nước lớn, đoạn giới thiệu ngắn, nút chính **“Let’s go”**.

* **Hành động:** Nhấn **Let’s go** → bắt đầu các bước onboarding.

### **2\) Bước 1 — Chọn giới tính**

* **UI:** Tiêu đề **“Select your gender”**, 2 thẻ chọn (**Male**, **Female**), thanh tiến trình phía trên, nút **Back** (mũi tên), nút **Next**.

* **Hành động:**

  * Chạm vào thẻ giới tính để chọn.

  * Nhấn **Next** → sang bước Cân nặng.

### **3\) Bước 2 — Nhập cân nặng**

* **UI:** Tiêu đề **“Weight”**, chuyển đơn vị **kg / lb**, bộ chọn số dạng cuộn (wheel picker), nút **Next**.

* **Hành động:**

  * Chọn đơn vị (kg hoặc lb).

  * Cuộn để chọn cân nặng.

  * Nhấn **Next** → sang bước Giờ thức dậy.

###  **4\) Bước 3 — Chọn giờ thức dậy**

* **UI:** Tiêu đề **“What time do you wake up”**, bộ chọn giờ (giờ/phút \+ AM/PM), nút **Next**.

* **Hành động:** Chọn giờ thức dậy → **Next** → sang bước Giờ đi ngủ.

### **5\) Bước 4 — Chọn giờ đi ngủ**

* **UI:** Tiêu đề **“What time do you go to bed”**, bộ chọn giờ, nút **Next**.

* **Hành động:** Chọn giờ đi ngủ → **Next** → sang phần Cài đặt nhắc nhở.

### **6\) Cài đặt nhắc nhở**

* **UI:** Tiêu đề **“Settings”**, các mục có thể chỉnh:

  * **Interval** (Ví dụ: “1 hour 30 min”) có icon chỉnh sửa

  * **Sound effect / Ringtone** có icon chỉnh sửa

  * **Vibrate** (rung) dạng công tắc bật/tắt

  * Nút chính **Next**

* **Chi tiết thao tác:**

  * Chạm **Interval (edit)** → mở **bottom sheet** chọn giờ/phút → **Save** để lưu khoảng nhắc.

  * Chạm **Sound effect (edit)** → mở **bottom sheet** danh sách âm thanh (radio chọn 1\) → **Save** để lưu âm.

  * Bật/tắt **Vibrate**.

  * Nhấn **Next** → chuyển sang xin quyền thông báo.

### **7\) Popup xin quyền thông báo**

* **UI:** Hộp thoại giữa màn hình với nội dung kiểu **“You’ll get reminder on time”** và nút **Allow**.

* **Hành động:** Nhấn **Allow** → gọi hộp xin quyền thông báo của hệ điều hành (nếu cần) → tiếp tục sang mục Mục tiêu hằng ngày.

### **8\) Mục tiêu uống nước hằng ngày**

* **UI:** Tiêu đề **“Daily Goal”**, giọt nước hiển thị mục tiêu mặc định (ví dụ **2000 ml**), nút **Start**.

* **Hành động:**

  * Nhấn **Start** → mở bottom sheet **Set daily goal**.

  * Bottom sheet có chuyển đơn vị **ml / oz**, bộ chọn số, nút **Save**.

  * Nhấn **Save** → xác nhận mục tiêu uống nước mỗi ngày.

## **Hoàn tất**

### **Điều hướng sang màn “Today” (Hôm nay)**

* Sau khi **lưu mục tiêu hằng ngày**, onboarding kết thúc.

* **Điều hướng:** `OnboardingComplete → Today`

* **Kết quả:** Người dùng vào màn **Today (Hôm nay)** để xem tiến độ trong ngày và nhận nhắc uống nước.

  **Dữ liệu thu thập trong onboarding (nên lưu lại)**  
* Giới tính

* Cân nặng \+ đơn vị (kg/lb)

* Giờ thức dậy

* Giờ đi ngủ

* Khoảng thời gian nhắc (interval)

* Âm thanh nhắc (sound effect/ringtone)

* Bật/tắt rung (vibrate)

* Mục tiêu uống nước hằng ngày \+ đơn vị (ml/oz)

2. **Tab today** 

## **1\) Today – Màn hình chính (Dashboard)**

**Mục đích:** Theo dõi lượng nước đã uống và nhắc lịch uống tiếp theo.

**Thành phần UI chính:**

* **Header:** “Stay hydrated” \+ mô tả “Track your water intake”.

* **Icon chuông (góc phải):** truy cập **Reminder settings** (cài nhắc uống).

* **Thẻ nhắc tiếp theo:** “Next reminder 06:00 pm” \+ dòng phụ “(… min left)”.

* **Vòng tròn tiến độ (progress ring):** hiển thị tiến độ ngày, ví dụ **1500 / 2000 ml** với giọt nước ở giữa.

* **2 nút nhanh (quick actions) dưới vòng tròn:**

  * **Physical activity** (hoạt động thể chất)

  * **Weather** (thời tiết)

* **CTA “Add Drink”:** thêm lượng nước vừa uống (mở flow/add form – không hiển thị chi tiết trong ảnh).

* **Bottom tab bar:** Today (đang chọn), History, Explore, Settings.

## **2\) Physical Activity – Popup chọn mức vận động**

**Cách mở:** Từ Today Dashboar d → bấm nút **Physical activity**.

**Nội dung:**

* Dạng **dialog/bottom sheet** tiêu đề “Physical Activity”.

* Chọn 1 trong các mức (radio):

  * **Sedentary** (+0 ml)

  * **Light active** (+250 ml)

  * **Moderate active** (+600 ml)

  * **Very active** (+1000 ml)

* Nút **Submit**: áp dụng mức vận động → hệ thống điều chỉnh mục tiêu/khuyến nghị lượng nước tương ứng.

**3\) Weather – Popup chọn điều kiện thời tiết**

**Cách mở:** Từ Today Dashboard → bấm nút **Weather**.

**Nội dung:**

* Dạng **dialog/bottom sheet** tiêu đề “Weather”.

* Chọn 1 trong các mức (radio) kèm gợi ý bù thêm nước:

  * **Cold** (+250 ml) / \< 18°C

  * **Normal** (+0 ml) / 18–25°C

  * **Warm** (+300 ml) / 26–30°C

  * **Hot** (+600 ml) / \> 30°C

* Nút **Submit**: áp dụng thời tiết → điều chỉnh mục tiêu/khuyến nghị.

## **4\) Reminder – Màn hình cài nhắc uống (truy cập từ icon chuông)**

**Cách mở:** Today Dashboard → bấm **icon chuông**.

**Mục đích:** Bật/tắt nhắc uống và chọn cách nhắc (theo lịch chuẩn, theo khoảng, hoặc tùy chỉnh).

### **4.1 Cấu trúc chung**

* **Enable Reminder:** bật/tắt nhắc uống nước.

* **Repeat Reminder:** chọn ngày lặp (mặc định weekdays) → mở danh sách **Monday…Sunday** để tick chọn.

* **Sound & Effect:** chọn **sound effect** (radio list) \+ bật/tắt **Vibrate**.

* **3 chế độ nhắc:**

  1. **Standard Mode** (theo lịch sinh hoạt)

  2. **Interval Mode** (nhắc theo khoảng thời gian cố định)

  3. **Custom Mode** (tự đặt nhiều mốc giờ)

Thường chỉ bật 1 mode chính để tránh trùng lịch.

### **4.2 Standard Mode (lịch chuẩn theo bữa/ngủ)**

* Danh sách các mốc nhắc (mỗi mốc có **giờ** \+ **toggle** bật/tắt):

  * After Wake-up, Before Breakfast, After Breakfast, Before Lunch, After Lunch, Before Dinner, After Dinner, Before sleep…

* Chạm vào giờ của 1 mốc → mở **bottom sheet chỉnh giờ** (time picker) → **Save**.

### **4.3 Interval Mode (nhắc theo khoảng)**

* Có mục **Interval** (ví dụ 1 hour…) → bấm edit mở **bottom sheet** chọn giờ/phút → **Save**.

* Có mục **Bedtime / Sleep time start & end**:

  * Chọn **Sleep time start** (giờ bắt đầu ngủ)

  * Chọn **Sleep time end** (giờ kết thúc ngủ)  
     → đều mở **time picker** → **Save**.

* Mục tiêu: nhắc uống theo chu kỳ trong “thời gian không ngủ”.

### **4.4 Custom Mode (tự chọn nhiều mốc giờ)**

* Hiển thị dạng **grid các “time chips”** (06:00, 08:00, 09:30…).

* Có nút **\+ Add**:

  * Mở time picker → **Add** để thêm mốc mới.

* Bấm vào 1 mốc giờ đã có:

  * Mở popup edit → **Remove** hoặc **Save** (cập nhật giờ).

**3\. History**

**1\) History – Tổng quan chung**

**Mục đích:** Theo dõi lịch sử uống nước và so sánh tiến độ theo thời gian.

**Bố cục chung (cả 3 chế độ):**

* **Header:** tiêu đề **History** \+ nút **Back**.

* **Bộ chọn chế độ:** 3 tab nhỏ **Day / Week / Month** (segment).

* **Khối thống kê \+ biểu đồ:** hiển thị tổng lượng uống và biểu đồ dạng cột (bar chart).

* **Bottom tab bar:** Today / History (đang chọn) / Explore / Settings.

## **2\) History – Chế độ Day (Theo ngày)**

## **Hiển thị:**

* Dòng ngày đang xem: **Today** (hoặc một ngày cụ thể nếu chuyển ngày).

* **Total:** tổng lượng uống trong ngày, ví dụ `1500 / 2000 ml`.

* **Biểu đồ cột theo giờ:** trục ngang là các mốc giờ trong ngày, mỗi cột thể hiện lượng uống tại thời điểm đó.

**Drink History (Danh sách chi tiết):**

* Bên dưới biểu đồ là danh sách các lần uống trong ngày.

* Mỗi item gồm:

  * **Thời gian** (ví dụ 09:00 PM)

  * **Loại đồ uống** (Water, Beer, Soup, Tea, Juice, Coffee, Milk…)

  * **Dung tích** (ml)

  * **Icon chỉnh sửa** (bút) ở bên phải (để sửa entry).

**Tương tác thường có:**

* Chọn **Day** để xem chi tiết từng lần uống.

* Nhấn icon **edit** để cập nhật loại/định lượng/thời gian (tuỳ thiết kế).

* Có thể chuyển ngày bằng thao tác điều hướng (mũi tên/đổi ngày) nếu app có.

---

## **3\) History – Chế độ Week (Theo tuần)**

**Hiển thị:**

* Dòng thời gian theo tuần, ví dụ: **Dec 15 – Dec 21, 2025**.

* **Total:** tổng lượng uống (và/hoặc trung bình) trong tuần.

* **Biểu đồ cột theo ngày trong tuần:** Mon → Sun, mỗi cột là tổng lượng uống của ngày đó.

**Mục đích:**

* Nhìn nhanh ngày nào uống nhiều/ít.

* So sánh thói quen uống nước giữa các ngày trong tuần.

**Tương tác thường có:**

* Chuyển sang tuần trước/tuần sau (nếu có điều hướng).

* Có thể chạm vào một cột để xem chi tiết ngày đó (nếu app hỗ trợ drill-down).

---

## **4\) History – Chế độ Month (Theo tháng)**

**Hiển thị:**

* Dòng thời gian theo tháng, ví dụ **December 2025**.

* **Total:** tổng lượng uống trong tháng (hoặc trung bình tuỳ thiết kế).

* **Biểu đồ cột theo ngày trong tháng:** trục ngang là các mốc ngày (01, 06, 11, 16, 21, 26, 31…), mỗi cột là tổng lượng uống trong ngày đó.

**Mục đích:**

* Xem xu hướng cả tháng, phát hiện các giai đoạn uống ít/nhiều.

* Đánh giá sự ổn định của thói quen uống nước.

**Tương tác thường có:**

* Chuyển tháng trước/tháng sau.

* Có thể chạm vào ngày cụ thể để xem chi tiết (nếu có).

**4\. Tab Explore** 

## **Explore – Màn hình thư viện nội dung**

**Mục đích:** Cung cấp bài viết/ngắn dạng card về:

* cách uống nước đúng,

* lợi ích sức khỏe,

* chăm sóc da,

* nội dung theo mùa/tình huống (làm việc, ốm, nóng/lạnh…).

### **1\) Bố cục tổng quan**

* **Header:** tiêu đề **Explore** ở giữa.

* **Danh sách nội dung theo nhóm (sections):** mỗi nhóm có tiêu đề và các card dạng thumbnail.

* **Bottom tab bar:** Today / History / Explore (đang chọn) / Settings.

### **2\) Các nhóm nội dung (sections) trên màn hình**

Trong ảnh có các nhóm chính sau:

#### **A) Drink Water**

* Các card nội dung hướng dẫn uống nước đúng cách, ví dụ:

  * “How to Drink Water Properly”

  * “Be careful with these common…”

  * “Benefits of drinking lemon…”

#### **B) Health Benefits**

* Nội dung về lợi ích sức khỏe, ví dụ:

  * “How water helps you sleep better”

  * “Drinking water and weight loss”

  * “Drinking water and the digestive…”

  * “The effects of water on the brain…”

  * “Impact of alcohol on your…”

  * “Drinking water to reduce hormon…”

#### **C) Healthier Skin**

* Nội dung tập trung vào da và thói quen uống nước, ví dụ:

  * “How to drink water to reduce…”

  * “Water-drinking mistakes that…”

  * “Best times to drink water for…”

  * “Drinking water during your peri…”

  * “Hydration for pregnant women”

#### **D) Seasonal & Situational Content**

* Nội dung theo hoàn cảnh/điều kiện, ví dụ:

  * “How much water should you drink…”

  * “Hydration tips while working…”

  * “Hydration tips when sick (fever, cold)”

  * “Hydration tips for office workers”

### **3\) Card nội dung (Article Card)**

Mỗi card thường gồm:

* Ảnh minh họa (thumbnail)

* Tiêu đề bài (có thể bị rút gọn “…”)

* (Tuỳ thiết kế) có thể có tag/nhóm hoặc indicator xem thêm

### **4\) Tương tác dự kiến**

* **Scroll dọc:** xem thêm nhiều nhóm nội dung.

* **Scroll ngang trong từng section:** lướt qua các card.

* **Tap vào card:** mở màn hình **Article Detail** (chi tiết bài viết) để đọc nội dung đầy đủ (màn này chưa xuất hiện trong ảnh nhưng là flow tự nhiên của Explore).

Nếu bạn muốn, mình có thể viết luôn mô tả **màn Article Detail** (tiêu đề, ảnh cover, nội dung, mục “related posts”, nút share/save) để hoàn chỉnh flow cho tab Explore.

**5\. Settings**

##  **Settings – Màn hình Cài đặt chính**

**Mục đích:** Trung tâm quản lý gói Premium, widget, thông tin cá nhân và các thiết lập chung của ứng dụng.

**Các phần chính trên màn hình:**

* **Banner “Get premium” (Nâng cấp Premium)**

  * Thông điệp: “Mở khóa mọi tính năng và tắt quảng cáo”.

  * Chạm vào → mở màn **IAP/Paywall** (mua gói).

* **Widget**

  * Chạm vào → mở màn **Xem trước & chọn Widget**.

* **Personal info (Thông tin cá nhân)**

  * **Gender (Giới tính)**

  * **Weight (Cân nặng)**

  * **Height (Chiều cao)**

  * **Age (Tuổi)**

  * **Daily Goal (Mục tiêu hằng ngày)**

  * Mỗi dòng hiển thị giá trị hiện tại (ví dụ: Female, 42 kg, 162 cm, 24, 2000 ml). Chạm vào từng dòng → mở **popup/bottom sheet** để chỉnh sửa.

* **General (Chung)**

  * **Units (Đơn vị)**: ví dụ ml, kg, cm

  * **Time Format (Định dạng giờ)**: ví dụ 12h

  * Chạm vào → mở màn chỉnh đơn vị / định dạng giờ.

* **Settings (Thiết lập)**

  * **Theme (Giao diện)**: Dark/Light

  * **Language (Ngôn ngữ)**: English…

  * Chạm vào → mở màn **Theme / Language**.

* **More (Khác)**

  * **Rate app (Đánh giá app)**

  * **Feedback (Góp ý)**

**Thanh tab dưới:** Today / History / Explore / **Settings** (đang chọn)

---

## **2\) Widget – Màn hình xem trước & chọn widget**

**Mục đích:** Cho người dùng xem trước và chọn kiểu widget hiển thị ngoài màn hình chính (Home screen).

**Nội dung:**

* Tiêu đề: **Widget**

* Chia theo kích thước:

  * **Small (Nhỏ):** hiển thị tiến độ \+ nút nhanh “Add Drink”

  * **Medium (Vừa):** hiển thị tiến độ \+ nhắc tiếp theo \+ tổng uống hôm nay

  * **Large (Lớn):** widget dạng dashboard, có nút thêm nhanh nhiều mức và danh sách gần đây

* Có thể chọn widget bằng thao tác chạm (tuỳ bạn thiết kế: chọn ngay hoặc cần lưu).

---

## **3\) Personal info – Các popup chỉnh sửa thông tin cá nhân**

Mỗi mục mở một **bottom sheet/popup** đơn giản với nút **Save (Lưu)**.

### **3.1 Gender (Giới tính)**

* 2 thẻ chọn **Male / Female**

* **Save** để lưu.

### **3.2 Weight (Cân nặng)**

* Chuyển đơn vị **kg / lb**

* Chọn số bằng **wheel picker**

* **Save** để lưu cân nặng \+ đơn vị.

### **3.3 Height (Chiều cao)**

* Chuyển đơn vị **cm / m**

* Chọn số bằng wheel picker

* **Save** để lưu.

### **3.4 Age (Tuổi)**

* Chọn tuổi bằng wheel picker

* **Save** để lưu.

### **3.5 Daily Goal (Mục tiêu uống nước/ngày)**

* Chuyển đơn vị **ml / oz**

* Chọn mục tiêu (ví dụ 2000 ml)

* **Save** để lưu.

---

## **4\) General – Đơn vị & Định dạng giờ**

### **4.1 Units (Đơn vị)**

Bottom sheet gồm 3 nhóm:

* **Water (Nước):** ml / oz

* **Weight (Cân nặng):** kg / lb

* **Height (Chiều cao):** cm / m  
   Nhấn **Save** để áp dụng.

### **4.2 Time Format (Định dạng giờ)**

Bottom sheet gồm:

* **24-hour time** (Giờ 24h)

* **12-hour time** (Giờ 12h)

* **Follow the system** (Theo hệ thống)  
   Nhấn **Save** để áp dụng.

---

## **5\) Theme – Màn hình chọn giao diện**

**Mục đích:** Đổi giao diện sáng/tối, hoặc theo hệ thống.

**Nội dung:**

* Ảnh xem trước giao diện app

* Nút chọn: **Light (Sáng)** / **Dark (Tối)**

* Công tắc: **Follow the system (Theo hệ thống)**
