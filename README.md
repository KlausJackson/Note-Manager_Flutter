# Note Manager

```bash
cd noteapp
```

See API requests and responses examples in [Task Manager](https://github.com/KlausJackson/Task-Manager)

## API

| No. | Method | Route                 | Description             |
| --- | :----: | --------------------- | ----------------------- |
| 1   |  POST  | /api/v1/auth/register | Register a new user     |
| 2   |  POST  | /api/v1/auth/login    | Log in, get a token     |
| 3   | DELETE | /api/v1/auth/me       | Delete your own account |
| 4   |  GET   | /api/v1/sync/         | Sync data               |

| No. | Method | Route            | Description                         |
| --- | ------ | ---------------- | ----------------------------------- |
| 5   | POST   | /api/v1/notes    | Create a new note                   |
| 6   | GET    | /api/v1/notes    | Get notes (filter: tag, words, etc) |
| 7   | GET    | /api/v1/notes/id | Get a note                          |
| 8   | PUT    | /api/v1/notes/id | Update a note                       |

| No. | Method | Route                    | Description                 |
| --- | ------ | ------------------------ | --------------------------- |
| 9   | DELETE | /api/v1/notes/id         | Delete a note               |
| 10  | GET    | /api/v1/notes/trash      | Get all deleted notes       |
| 11  | PUT    | /api/v1/notes/id/restore | Restore a deleted note      |
| 12  | DELETE | /api/v1/notes/trash/id   | Permanently delete the note |

| No. | Method | Route           | Description                |
| --- | ------ | --------------- | -------------------------- |
| 13  | POST   | /api/v1/tags    | Create a new tag           |
| 14  | GET    | /api/v1/tags    | Get all of the user's tags |
| 15  | PUT    | /api/v1/tags/id | Update a tag's name        |
| 16  | DELETE | /api/v1/tags/id | Delete a tag               |

## Project Architecture

### Clean Architecture

```bash
lib/
├── core/
│   ├── network/
│   │   └── api_client.dart   
│   ├── routing/
│   │   └── app_router.dart
│   ├── dependencies/
│   │   └── dependency_injection.dart
│   └── constants.dart
│
├── features/
│   ├── auth/
│   │   ├── auth_dependencies.dart
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── auth_remote.dart
│   │   │   │   └── auth_local.dart
│   │   │   ├── models/
│   │   │   │   └── user_model.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user.dart
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_current_user.dart
│   │   │       ├── login.dart
│   │   │       ├── logout.dart
│   │   │       ├── register.dart
│   │   │       ├── delete_user.dart
│   │   │       ├── get_saved_users.dart
│   │   │       └── delete_saved_user.dart
│   │   └── presentation/
│   │       ├── provider/
│   │       │   └── auth_provider.dart
│   │       ├── pages/
│   │       │   └── auth_page.dart
│   │       └── widgets/
│   │           ├── user_list.dart
│   │           └── auth_form.dart
│   │
│   └── notes/
│       ├── note_dependencies.dart
│       ├── data/
│       │   ├── datasources/
│       │   │   ├── note_remote.dart
│       │   │   └── note_local.dart
│       │   ├── models/
│       │   │   ├── block_model.dart
│       │   │   └── note_model.dart
│       │   └── repositories/
│       │       └── note_repository_impl.dart
│       ├── domain/
│       │   ├── entities/
│       │   │   ├── block.dart
│       │   │   └── note.dart
│       │   ├── repositories/
│       │   │   └── note_repository.dart
│       │   └── usecases/
│       │       ├── create_note.dart
│       │       ├── get_notes.dart
│       │       ├── update_note.dart
│       │       ├── delete_note.dart
│       │       ├── sync_notes.dart
│       │       ├── get_trashed_notes.dart
│       │       ├── restore_note.dart
│       │       └── permanently_delete_note.dart
│       └── presentation/
│           ├── provider/
│           │   └── note_provider.dart
│           ├── pages/
│           │   ├── note_page.dart
│           │   ├── edit_page.dart
│           │   └── trash_page.dart
│           └── widgets/
│               ├── pagination.dart
│               ├── search_bar.dart
│               └── note_card.dart
│
├── presentation/ 
│   ├── pages/ 
│   │   └── main_layout_page.dart 
│   └── widgets/ 
│       ├── menu_drawer.dart
│       └── show_dialogs.dart 
│
├── app.dart
└── main.dart
```

### MVVC

```bash
lib/
├── core/
│   ├── constants.dart
│   └── date_formatter.dart
│
├── data/
│   ├── models/
│   │   ├── note.dart
│   │   ├── tag.dart
│   │   └── user.dart
│   │
│   ├── sources/
│   │   ├── local.dart   # local device database
│   │   └── remote.dart  # web API
│   │
│   └── services/
│       ├── auth.dart
│       ├── note.dart
│       ├── tag.dart
│       └── sync.dart
│
├── providers/              # State Management
│   ├── auth_provider.dart
│   ├── note_provider.dart
│   ├── tag_provider.dart
│   └── sync_provider.dart
│
└── presentation/
    ├── screens/
    │   ├── auth/
    │   │   └── auth.dart
    │   ├── notes/
    │   │   ├── note_list.dart
    │   │   ├── note_edit.dart
    │   │   └── trashed_list.dart
    │   └── tags/
    │       └── tag_list.dart
    │
    └── widgets/
        ├── note_card.dart
        ├── search_bar.dart
        ├── show_dialog.dart
        └── tag_chip.dart
```

### Luồng Dữ Liệu và Tính Năng

1.  **Fresh Start:** Người dùng mới có thể tạo ghi chú (notes) và thẻ (tags) mà không cần tài khoản. Dữ liệu được lưu trữ cục bộ trên thiết bị, liên kết với một hồ sơ mặc định chỉ có ở local. Để xóa một tài khoản, người dùng phải đăng nhập, nhập lại mật khẩu để xác nhận. Sau khi xóa thành công, người dùng sẽ cần đăng nhập vào một tài khoản khác hoặc có thể tiếp tục sử dụng ứng dụng ngoại tuyến (offline) mà không cần đăng nhập.
2.  **Optional Registration:** Người dùng có thể chọn đăng ký tài khoản. Khi đăng ký, ứng dụng sẽ kích hoạt một quy trình đồng bộ hóa (sync), đẩy tất cả dữ liệu được tạo cục bộ lên máy chủ và liên kết nó với tài khoản mới.

## Presentation

| Component           | API                                                                                         | Standard Widgets                                                                                         | Reusable Widgets                 | Description          |
| ------------------- | ------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------- | -------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Login; Register** | POST /api/v1/auth/register; POST /api/v1/auth/login                                         | TextField, TextButton, CircularProgressIndicator, ListView, Card                                         | CustomTextField                  | Input validation. Bao gồm một danh sách các hồ sơ người dùng đã lưu cục bộ bên dưới biểu mẫu để chọn đăng nhập nhanh.                                                            |
| **Notes List**      | GET /api/v1/notes                                                                           | ListView / GridView, FloatingActionButton, RefreshIndicator, CheckboxListTile, CircularProgressIndicator | Note Card | - Thanh `Search & Filter`.<br>- Hiển thị ghi chú.<br>- Kéo để làm mới (Pull-to-refresh) để đồng bộ dữ liệu.<br>- `Floating Action Button` để tạo ghi chú mới. |
| **Note Edit**       | POST /api/v1/notes<br>PUT /api/v1/notes/id<br>DELETE /api/v1/notes/id                       | TextField, ListView, Wrap, IconButton, TextButton                                                        | Tag Chip                         | <ul><li>Danh sách động các khối nội dung (body blocks): có thể biến dòng hiện tại thành văn bản hoặc dạng văn bản + checkbox (checklist).</li><li>Giao diện chọn thẻ.</li><li>Các hành động lưu/hủy/xóa.</li></ul> |
| **Trashed List**    | GET /api/v1/notes/trash <br>PUT /api/v1/notes/id/restore <br> DELETE /api/v1/notes/trash/id | ListView, ListTile, CheckboxListTile, AlertDialog  | Note Card | - Hiển thị các ghi chú đã xóa.<br>- Người dùng có thể khôi phục ghi chú trở lại danh sách chính hoặc xóa vĩnh viễn. |
| **Tag List**        | POST /api/v1/tags<br>GET /api/v1/tags<br>PUT /api/v1/tags/id<br>DELETE /api/v1/tags/id       | FloatingActionButton, CheckboxListTile, ListView, ListTile, IconButton, AlertDialog, TextField       | Tag Chip                         | <ul><li>Liệt kê tất cả các thẻ của người dùng</li><li>Tạo thẻ mới</li><li>Đổi tên thẻ</li><li>Xóa thẻ thông qua dialogs</li></ul> |

## ShowDialog

### showInfoDialog

Dialog với `title`, `message`, và nút `OK`: dùng cho thông báo lỗi / thông tin.

```dart
AppDialogs.showInfoDialog(
  context: context,
  title: 'Lỗi',
  message: 'Không thể lưu ghi chú.',
  // onOkPressed: goi ham chuc nang
);

AppDialogs.showInfoDialog(
  context: context,
  title: 'Thành công',
  message: 'Đã lưu ghi chú.',
);
```

### showConfirmationDialog

Dialog với nút `Cancel` và một hành động xác nhận: dùng cho việc xóa.

```dart
AppDialogs.showConfirmationDialog(
  context: context,
  title: 'Xóa Ghi Chú?',
  message: 'Hành động này không thể hoàn tác.',
  confirmText: 'Xóa',
  onConfirm: () {
    // code xoa note ở đây
  },
);
```

### showInputDialog

Dialog với một trường nhập liệu (input field) và các nút `Cancel`/`Confirm`: dùng để xác nhận mật khẩu, đổi tên thẻ.
Hàm này trả về `String` đã nhập nếu xác nhận, hoặc `null` nếu hủy.

```dart
AppDialogs.showInputDialog(
    context: context,
    title: 'Xác Nhận Xóa Tài Khoản',
    message: 'Vui lòng nhập lại mật khẩu của bạn:',
    confirmText: 'Xóa',
).then((password) {
    if (password != null && password.isNotEmpty) {
        _authProvider.deleteAccount(password);
    } else if (password != null && password.isEmpty) {
        _snackbar('Mật khẩu không được để trống.');
    }
});
```
