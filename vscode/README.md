# VSCode Settings

These are my preffered vscode settings, using a combination of vscode keybinds and vim keybinds.

## Manual Installation

Belov are the steps to take the files from this repo to setup vscode.

### Step 1: Take `settings.json` and `keybinds.json` file and the `snippets/` folder and add it to your vscode folder.

#### Default VSCode location

**Windows:**

```
C:/Users/<your name>/AppData/Roaming/Code/User
```

**Mac:**

```
~/Library/Application Support/Code/User
```

### Step 2: Intall extensions

Open terminal in VS Code and run:

```
cat extensions.txt | xargs -n 1 code --install-extension
```

## Manual Export

- Copy content of `settings.json`, `keybinds.json`, and `snippets/` into repo
- Run `code --list-extensions > extensions.txt` and add the file to the repo
