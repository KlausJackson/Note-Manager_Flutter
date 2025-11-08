# Note Manager Flutter

Switch to clean-architecture_notes for full code source (except for tags). <br>
See API requests and responses examples in [Task Manager](https://github.com/KlausJackson/Task-Manager)

## API

| No. | Method | Route                 | Description             |
| --- | :----: | --------------------- | ----------------------- |
| 1   |  POST  | /api/v1/auth/register | Register a new user     |
| 2   |  POST  | /api/v1/auth/login    | Log in, get a token     |
| 3   | DELETE | /api/v1/auth/me       | Delete your own account |
| 4   |  GET   | /api/v1/sync/         | Sync data               |

<hr>

| No. | Method | Route            | Description                         |
| --- | ------ | ---------------- | ----------------------------------- |
| 5   | POST   | /api/v1/notes    | Create a new note                   |
| 6   | GET    | /api/v1/notes    | Get notes (filter: tag, words, etc) |
| 7   | GET    | /api/v1/notes/id | Get a note                          |
| 8   | PUT    | /api/v1/notes/id | Update a note                       |

<hr>

| No. | Method | Route                    | Description                 |
| --- | ------ | ------------------------ | --------------------------- |
| 9   | DELETE | /api/v1/notes/id         | Delete a note               |
| 10  | GET    | /api/v1/notes/trash      | Get all deleted notes       |
| 11  | PUT    | /api/v1/notes/id/restore | Restore a deleted note      |
| 12  | DELETE | /api/v1/notes/trash/id   | Permanently delete the note |

<hr>

| No. | Method | Route           | Description                |
| --- | ------ | --------------- | -------------------------- |
| 13  | POST   | /api/v1/tags    | Create a new tag           |
| 14  | GET    | /api/v1/tags    | Get all of the user's tags |
| 15  | PUT    | /api/v1/tags/id | Update a tag's name        |
| 16  | DELETE | /api/v1/tags/id | Delete a tag               |

## Project Architecture

### NEW

```bash
lib/
├── core/
# │   ├── error/
# │   │   ├── exceptions.dart
# │   │   └── failure.dart
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
│   ├── sync/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── sync_remote.dart
│   │   │   └── repositories/
│   │   │       └── sync_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── repositories/
│   │   │   │   └── sync_repository.dart
│   │   │   └── usecases/
│   │   │       └── perform_sync.dart 
│   │   └── presentation/
│   │       └── provider/
│   │           └── sync_provider.dart
│   │
│   ├── notes/
│   │   ├── note_dependencies.dart
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── note_remote.dart
│   │   │   │   └── note_local.dart
│   │   │   ├── models/
│   │   │   │   ├── block_model.dart
│   │   │   │   └── note_model.dart
│   │   │   └── repositories/
│   │   │       └── note_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── block.dart
│   │   │   │   └── note.dart
│   │   │   ├── repositories/
│   │   │   │   └── note_repository.dart
│   │   │   └── usecases/
│   │   │       ├── create_note.dart
│   │   │       ├── get_notes.dart
│   │   │       ├── update_note.dart
│   │   │       ├── delete_note.dart
│   │   │       ├── get_trashed_notes.dart
│   │   │       ├── restore_note.dart
│   │   │       └── permanently_delete_note.dart
│   │   └── presentation/
│   │       ├── provider/
│   │       │   └── note_provider.dart
│   │       ├── pages/
│   │       │   ├── note_page.dart
│   │       │   ├── edit_page.dart
│   │       │   └── trash_page.dart
│   │       └── widgets/
│   │           ├── note_card.dart
│   │           └── search_filter_bar.dart
│   │
│   └── tags/
│       ├── tag_dependencies.dart
│       ├── data/
│       │   ├── datasources/
│       │   │   ├── tag_remote.dart
│       │   │   └── tag_local.dart
│       │   ├── models/
│       │   │   └── tag_model.dart
│       │   └── repositories/
│       │       └── tag_repository_impl.dart
│       ├── domain/
│       │   ├── entities/
│       │   │   └── tag.dart
│       │   ├── repositories/
│       │   │   └── tag_repository.dart
│       │   └── usecases/
│       │       ├── create_tag.dart
│       │       ├── get_tags.dart
│       │       ├── update_tag.dart
│       │       └── delete_tag.dart
│       └── presentation/
│           ├── provider/
│           │   └── tag_provider.dart
│           ├── pages/
│           │   └── tag_list_page.dart
│           └── widgets/
│               └── tag_chip.dart
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

### OLD

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

### Data Flow

1.  **Fresh Start:** new users can create notes and tags without needing an account. Data is stored locally on the device, linked to a default local-only profile. To delete an account, the user must log in, re-enter the account password. Once the deletion is successful, the user will need to log into an account again or can continue to use the app offline without being logged in.
2.  **Optional Registration:** user can choose to register an account. Upon registration, the app will trigger a sync process, pushing all locally created data to the server and linking it to the new account.
3.  **Layered Communication:**
    -   **Presentation (UI)** sends user events to the **Providers**.
    -   **Providers** execute business logic and call methods on the **Services**.
    -   **Services** fetch data from **Local Storage** before fetching from the **API**.

## Presentation

### Widgets

| Custom Widget           | Description                                                          |
| ----------------------- | -------------------------------------------------------------------- |
| **Search & Filter Bar** | A text field for search and a button to open a tag filter panel.     |
| **Note Card**           | A card that displays a preview of a note's title, body, and tags.    |
| **Tag Chip**            | A small "pill" widget that displays a tag's name; can be selectable. |
| **Custom ShowDialog**   | Custom dialogs for all use cases: destruction, create, confirm, etc. |

### Screens

This part is outdated. <br>
BottomNavigation to switch between Note List, Tag List, Trashed List.

| Component           | API                                                                                         | Standard Widgets                                                                                         | Reusable Widgets                 | Description                                                                                                                                                                                     |
| ------------------- | ------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------- | -------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Login; Register** | POST /api/v1/auth/register; POST /api/v1/auth/login                                         | TextField, TextButton, CircularProgressIndicator, ListView, Card                                         | CustomTextField                  | Input validation. Includes a list of locally saved user profiles below the form for quick login selection.                                                                                      |
| **Notes List**      | GET /api/v1/notes                                                                           | ListView / GridView, FloatingActionButton, RefreshIndicator, CheckboxListTile, CircularProgressIndicator | Search & Filter Bar<br>Note Card | - Search & Filter bar next to Account button (right) on top.<br>- Displays notes.<br>- Pull-to-refresh action to sync data.<br>- Floating Action Button to create a new note. |
| **Note Edit**       | POST /api/v1/notes<br>PUT /api/v1/notes/id<br>DELETE /api/v1/notes/id                       | TextField, ListView, Wrap, IconButton, TextButton   | Tag Chip     | <ul><li>Dynamic list of body blocks: can turn the current line into a text or checklist.</li><li>Tag selection interface.</li><li>Save/delete actions.</li></ul>    |
| **Trashed List**    | GET /api/v1/notes/trash <br>PUT /api/v1/notes/id/restore <br> DELETE /api/v1/notes/trash/id | ListView, ListTile, CheckboxListTile, AlertDialog    | Search & Filter Bar<br>Note Card | - Displays deleted notes.<br>- Users can restore a note back to the main list or permanently delete notes.   |
| **Tag List**        | POST /api/v1/tags<br>GET /api/v1/tags<br>PUT /api/v1/tags/id<br>DELETE /api/v1/tags/id | FloatingActionButton, CheckboxListTile, ListView, ListTile, IconButton, AlertDialog, TextField | Tag Chip | <ul><li>List all user tags</li><li>Create new tags</li><li>Rename tags</li><li>Delete tags via dialogs</li></ul>  |


## ShowDialog

### showInfoDialog

Dialog with title, message, ok button: error / info

```dart
AppDialogs.showInfoDialog(
  context: context,
  title: 'Error',
  message: 'Could not save the note.',
  // onOkPressed: goi ham chuc nang
);

AppDialogs.showInfoDialog(
  context: context,
  title: 'Success',
  message: 'Saved the note.',
);
```

### showConfirmationDialog

Dialog with cancel and confirmation action: delete

```dart
AppDialogs.showConfirmationDialog(
  context: context,
  title: 'Delete Note?',
  message: 'This action cannot be undone.',
  confirmText: 'Delete',
  onConfirm: () {
    // code xoa note
  },
);
```

### showInputDialog

Dialog with input field and cancel/confirm actions: password confirmation, change tag name
Returnstheinputtextifconfirmed,nullifcancelled.

```dart
AppDialogs.showInputDialog(
    context: context,
    title: 'Confirm Account Deletion',
    message: 'Please re-enter your password:',
    confirmText: 'Delete',
    ).then((password) {
        if (password != null && password.isNotEmpty) {
            _authProvider.deleteAccount(password);
        } else if (password != null && password.isEmpty) {
            _snackbar('Password cannot be empty.');
        }
    }
);
```
