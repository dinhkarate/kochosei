##06/09/2024

superjump_lag
superjump
superjump_land

jump
fallwarn
fall

Cần phải viết lại SG trong các phase jump fall fallwarn fallpost. -> Đã viết lại xuất sắc
Có thể dựa trên SG của sonoko hoặc dựa trên SG của item trong mod The Forge để biết.

Các vấn đề đã phát hiện:
+ Viết lại tigersharkduke_shadow để có thể tạo hiệu ứng bóng khi nó rơi xuống -> Không cần thiết viết lại, nó có thể dùng được mà không ảnh hưởng gì (cho đến hiện tại) (07/09)
+ Viết lại SG của tigershark_duke. Các SG của nó khá hoàn thiện rồi. Vì vậy chỉ cần sửa lại SG khi bay nhảy và khi tấn công -> (07/09) Đã sửa lại hoàn thiện SG
+ Sửa lại Tag cho các SG, nghi vấn các tag làm xảy ra hiện tượng 3 tay. -> (07/09) Các tag không làm xuất hiện hiện tượng 3 tay

Mong muốn: 
+ Con Kochosei sẽ không cầm bất kỳ vũ khí nào, chỉ đánh bằng tay không. -> Đã sửa được, có thể chỉnh bất kỳ loại anim nào mong muốn (07/09)
+ Loại bỏ hiện tượng 3 tay. -> Đã loại bỏ hiện tượng 3 tay bằng inst.AnimState:Hide("ARM_carry") (07/09)



#(07/09)
Đang thắc mắc cách hoạt động của brain và SG. Thật sự không hiểu cách là nó vào phase taunt và phase jump như thế nào. Trong brain không thấy đề cập bất cứ gì cả. Trong prefab cũng không.

Nhưng cấu thành logic của một entity chỉ cần 3 file đó là được. Về mặt Brain khá khó hiểu, mình chỉ hiểu mấy cái cơ bản như chaseattack, leash các thứ, còn các behaviour còn lại thì không hiểu hoàn toàn.

Update:
+ Xuất sắc sử dụng make() để return nhiều prefab với đối số khác nhau. Khó khăn là phải dùng hàm ẩn danh. Nếu dùng hàm có sẵn và truyền đối số vào thì sẽ không hoạt động (không rõ nguyên nhân)

+ Hàm ẩn danh:
Ví dụ hàm ẩn danh
inst:DoPeriodicTask(2, function()
    print("This will print every 2 seconds.")
end)

Ví dụ hàm ẩn danh có gán biến
local myFunction
myFunction = function()
    print("Hello, World!")
end

+ Thao tác với FX thuần phục. Hiểu cách sử dụng FX trong nhiều tình huống.

+ Fix vấn đề SetSpeed cho khi hoá khỉ.


Mong muốn cho lần tiếp theo:
+ Loại bỏ những thứ dư thừa trong code, đặc biệt là prefab để code gọn lại.
+ Hiểu được cách hoạt động của brain và stategraph. Hiện tại có thể dùng stategraph trong prefab nhưng không hiểu cách nó hoạt động cùng brain như thế nào.
+ Thay đổi tên của file, cũng như tên prefab.
+ Nếu đã hiểu được cách hoạt động của brain và stategraph với nhau. Hãy thử cho kochosei cầm một cây gậy và triệu hồi ra con xương trong một khoảng thời gian ngắn sau đó cho con xương chết.
+ Thay đổi UI cho Altar
+ Quyết định giữ Altar hay sử dụng cây tử đằng thay thế cho Altar!
+ Định nghĩa cách spawn cho kochosei_shadow
+ Đổi tên kochosei_shadow. Vì kochosei_shadow được dùng cho con sau này có skill teleport như shadow_bishop.



Tiến hành lại quy trình khi đổi tên.
1. Đổi tên thành phần + commit
2. Đổi tên File

Mục đích để tường minh hơn và biết rõ hơn mình đã thay đổi ở đâu

kochosei_duke có 3 hành động chính khi tương tác với player
1. Triệu hồi bão
2. Bay
3. Đánh


Chase and Attack

Charge Behaviour <Success>
Chase and Ram   <Success>
Hai cái này thoả mãn thì kochosei_duke sẽ nhảy
Làm thế nào mà ChaseAndRam(...) lại biết cho SG thực hiện sg jump -> từ sg jump sẽ dẫn đến các sg khác. Tại sao là sg jump chứ không phải là sg khác? Làm thế nào mà ChaseAndRam nhận diện được

-> Bằng cách xác định tag (Chỉ một phần) -> Phải xem nhiều SG hơn mới hiểu được