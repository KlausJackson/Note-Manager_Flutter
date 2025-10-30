import os

PROJECT_NAME = "noteapp-test"
BASE_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), PROJECT_NAME, "lib")

ARCHITECTURE_MAP = {
    "app.dart": None,
    "main.dart": None,
    "core": {
        "constants.dart": None,
        "network": ["api_client.dart", "network_info.dart"],
        "routing": ["app_router.dart"],
        "usecase": ["usecase.dart"],
    },
    "features": {
        "auth": {
            "data": {
                "datasources": ["auth_remote.dart", "auth_local.dart"],
                "models": ["user_model.dart"],
                "repositories": ["auth_repository_impl.dart"],
            },
            "domain": {
                "entities": ["user.dart"],
                "repositories": ["auth_repository.dart"],
                "usecases": ["login_user.dart", "register_user.dart", "logout.dart", "delete_user.dart", "get_saved_users.dart", "delete_saved_user.dart"],
            },
            "presentation": {
                "provider": ["auth_provider.dart"],
                "pages": ["auth_page.dart"],
                "widgets": ["auth_form.dart", "profile_list.dart"],
            },
        },
        "notes": {
            "data": {
                "datasources": ["note_remote.dart", "note_local.dart"],
                "models": ["note_model.dart", "block_model.dart"],
                "repositories": ["note_repository_impl.dart"],
            },
            "domain": {
                "entities": ["note.dart", "block.dart"],
                "repositories": ["note_repository.dart"],
                "usecases": ["create_note.dart", "get_notes.dart", "update_note.dart", "delete_note.dart", "get_trashed_notes.dart", "restore_note.dart", "permanently_delete_note.dart"],
            },
            "presentation": {
                "provider": ["note_provider.dart"],
                "pages": ["note_list_page.dart", "note_edit_page.dart", "trash_page.dart"],
                "widgets": ["note_card.dart", "search_filter_bar.dart"],
            },
        },
        "sync": {
            "data": {
                "datasources": ["sync_remote.dart"],
                "repositories": ["sync_repository_impl.dart"],
            },
            "domain": {
                "repositories": ["sync_repository.dart"],
                "usecases": ["perform_sync.dart"],
            },
            "presentation": {
                "provider": ["sync_provider.dart"],
            },
        },
        "tags": {
            "data": {
                "datasources": ["tag_remote.dart", "tag_local.dart"],
                "models": ["tag_model.dart"],
                "repositories": ["tag_repository_impl.dart"],
            },
            "domain": {
                "entities": ["tag.dart"],
                "repositories": ["tag_repository.dart"],
                "usecases": ["create_tag.dart", "get_tags.dart", "update_tag.dart", "delete_tag.dart"],
            },
            "presentation": {
                "provider": ["tag_provider.dart"],
                "pages": ["tag_list_page.dart"],
                "widgets": ["tag_chip.dart"],
            },
        },
        "home": {
            "presentation": {
                "pages": ["home_page.dart"],
            }
        }
    },
    "presentation": { # Shared presentation layer
        "widgets": ["show_dialogs.dart"],
    }
}


def create_files(base_dir, structure):
    for name, content in structure.items():
        path = os.path.join(base_dir, name)
        if isinstance(content, dict):
            # It's a directory
            os.makedirs(path, exist_ok=True)
            create_files(path, content)
        elif isinstance(content, list):
             # It's a directory with a list of files
            os.makedirs(path, exist_ok=True)
            for filename in content:
                file_path = os.path.join(path, filename)
                if not os.path.exists(file_path):
                    with open(file_path, 'w') as f:
                        f.write(f"// Placeholder for {filename}\n")
                    print(f"Created file: {file_path}")
        elif content is None:
            # It's a file at the current level
            if not os.path.exists(path):
                with open(path, 'w') as f:
                    f.write(f"// Placeholder for {name}\n")
                print(f"Created file: {path}")

def main():
    if not os.path.exists(BASE_PATH):
        return

    print("Starting to generate project architecture...")
    create_files(BASE_PATH, ARCHITECTURE_MAP)
    print("\nProject architecture generated successfully!")

if __name__ == "__main__":
    main()


# lib/
# ├── core/
# # │   ├── error/
# # │   │   ├── exceptions.dart
# # │   │   └── failure.dart
# │   ├── network/
# │   │   └── api_client.dart   
# │   ├── routing/
# │   │   └── app_router.dart
# │   ├── usecase/
# │   │   └── usecase.dart # base class for usecases
# # │   └── constants.dart
# # │   └── dependency_injection.dart 
# │
# ├── features/
# │   ├── home/ 
# │   │   └── presentation/
# │   │       └── pages/
# │   │           └── home_page.dart
# │   │
# │   ├── auth/
# │   │   ├── data/
# │   │   │   ├── datasources/
# │   │   │   │   ├── auth_remote.dart
# │   │   │   │   └── auth_local.dart
# │   │   │   ├── models/
# │   │   │   │   └── user_model.dart
# │   │   │   └── repositories/
# │   │   │       └── auth_repository_impl.dart
# │   │   ├── domain/
# │   │   │   ├── entities/
# │   │   │   │   └── user.dart
# │   │   │   ├── repositories/
# │   │   │   │   └── auth_repository.dart
# │   │   │   └── usecases/
# │   │   │       ├── login_user.dart
# │   │   │       ├── register_user.dart
# │   │   │       ├── delete_user.dart
# │   │   │       ├── get_saved_users.dart
# │   │   │       └── delete_saved_user.dart
# │   │   └── presentation/
# │   │       ├── provider/
# │   │       │   └── auth_provider.dart
# │   │       ├── pages/
# │   │       │   └── auth_page.dart
# │   │       └── widgets/
# │   │           ├── user_list.dart
# │   │           └── auth_form.dart
# │   │
# │   ├── sync/
# │   │   ├── data/
# │   │   │   ├── datasources/
# │   │   │   │   └── sync_remote.dart
# │   │   │   └── repositories/
# │   │   │       └── sync_repository_impl.dart
# │   │   ├── domain/
# │   │   │   ├── repositories/
# │   │   │   │   └── sync_repository.dart
# │   │   │   └── usecases/
# │   │   │       └── perform_sync.dart 
# │   │   └── presentation/
# │   │       └── provider/
# │   │           └── sync_provider.dart
# │   │
# │   ├── notes/
# │   │   ├── data/
# │   │   │   ├── datasources/
# │   │   │   │   ├── note_remote.dart
# │   │   │   │   └── note_local.dart
# │   │   │   ├── models/
# │   │   │   │   ├── block_model.dart
# │   │   │   │   └── note_model.dart
# │   │   │   └── repositories/
# │   │   │       └── note_repository_impl.dart
# │   │   ├── domain/
# │   │   │   ├── entities/
# │   │   │   │   ├── block.dart
# │   │   │   │   └── note.dart
# │   │   │   ├── repositories/
# │   │   │   │   └── note_repository.dart
# │   │   │   └── usecases/
# │   │   │       ├── create_note.dart
# │   │   │       ├── get_notes.dart
# │   │   │       ├── update_note.dart
# │   │   │       ├── delete_note.dart
# │   │   │       ├── get_trashed_notes.dart
# │   │   │       ├── restore_note.dart
# │   │   │       └── permanently_delete_note.dart
# │   │   └── presentation/
# │   │       ├── provider/
# │   │       │   └── note_provider.dart
# │   │       ├── pages/
# │   │       │   ├── note_list_page.dart
# │   │       │   ├── note_edit_page.dart
# │   │       │   └── trash_page.dart
# │   │       └── widgets/
# │   │           ├── note_card.dart
# │   │           └── search_filter_bar.dart
# │   │
# │   └── tags/
# │       ├── data/
# │       │   ├── datasources/
# │       │   │   ├── tag_remote.dart
# │       │   │   └── tag_local.dart
# │       │   ├── models/
# │       │   │   └── tag_model.dart
# │       │   └── repositories/
# │       │       └── tag_repository_impl.dart
# │       ├── domain/
# │       │   ├── entities/
# │       │   │   └── tag.dart
# │       │   ├── repositories/
# │       │   │   └── tag_repository.dart
# │       │   └── usecases/
# │       │       ├── create_tag.dart
# │       │       ├── get_tags.dart
# │       │       ├── update_tag.dart
# │       │       └── delete_tag.dart
# │       └── presentation/
# │           ├── provider/
# │           │   └── tag_provider.dart
# │           ├── pages/
# │           │   └── tag_list_page.dart
# │           └── widgets/
# │               └── tag_chip.dart
# │
# ├── presentation/ 
# │   └── widgets/ 
# │       └── show_dialogs.dart 
# │
# ├── app.dart
# └── main.dart