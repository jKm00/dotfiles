# VSCode Settings

These are my preferred vscode settings, using a combination of vscode keybinds and vim keybinds.

## Manual Installation

Below are the steps to take the files from this repo to setup vscode.

### Step 1: Copy `settings.json` and `keybindings.json` files to your vscode folder.

#### Default VSCode location

**Windows:**

```
C:/Users/<your name>/AppData/Roaming/Code/User
```

**Mac:**

```
~/Library/Application Support/Code/User
```

### Step 2: Install extensions

Open terminal in VS Code and run:

```
cat extensions.txt | xargs -n 1 code --install-extension
```

## Manual Export

- Copy content of `settings.json` and `keybindings.json` into repo
- Run `code --list-extensions > extensions.txt` and add the file to the repo
