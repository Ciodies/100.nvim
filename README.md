# 100.nvim
A neovim Plugin heavily inspired by the famous `99` and `telescope.nvim` neovim plugins.

## What is 100.nvim
`100.nvim` is a plugin built to provide support for highly customizable ai workflows.

## Noteworthy Features:
- Built from the ground up by hand (No AI was used)
- Full control over provider, model, prompt and context
- Simple and stable API
- Zero dependencies

## Motivation:
AI results are largely determined by the model, context, and prompt, and only reach their full potential when developers have complete control over all three. Now after coming to this conclusion and finding other available tools very lacking, I decided to build `100.nvim` to keep full control over each of these aspects.

## Table of Contents:
- [Getting started](#getting-started)
- [Usage](#usage)
- [Prompting strategies](#prompting-strategies)
- [Up and coming features](#up-and-coming-features)
- [Noteworthy mentions](#noteworthy-mentions)

## Getting started:
This section should guide you to run your keymap.

### Installation
Using Neovim 0.12 built-in plugin manager `vim.pack`:

```lua
vim.pack.add({
  "https://github.com/Ciodies/100.nvim",
})
```

Using `lazy.nvim`:

```lua
{
  "Ciodies/100.nvim",
  config = function()
  require("100.nvim").setup({
  -- optional configuration here
  })
  end
}
```

## Usage
Using this plugin is pretty straightforward and normally involves calling one of the many predefined window/helper functions. These functions provide developers with a convenient means to interact with their preferred LLM or AI agent.

### Helper function structure
It should be noted that each window/helper function follows the same structure. To call any of these functions, you will need to pass an `options` object (for fine-grained control) and a `callback` function (to interact with the AI agent).

```lua
require("100").helper_function(opts, callback)
```

### Available helper functions
Below you will find a list of available window/helper functions supported by this plugin. For demonstration purposes, all examples will use the claude-code CLI in the background to communicate with an AI agent. You can, however, use whatever ai tool you really feel like. For convenience, each example is wrapped in a keymap statement for easy setup.

#### create_window_search
This function allows the user to search for specific sections of code inside of a codebase starting from the current working directory. (May use a lot of tokens. Caution is advised)

```lua
vim.keymap.set("n", "<leader>ais", function()
  require("100").create_window_search({}, function (context, resolve, reject)
    local system_prompt = 'Given a specific prompt, you are responsible for finding relevant functions and sections starting from the current working directory.\n## rules:\n- your final message must follow the output format\n- your final message is not allowed to start with as notice (Example: Perfect ...)\n\n<Output Format>./testfolder/file.extension|starting line number|starting column number|span of lines|notes relevant to the prompt</Output Format>\n<Example Output>./testfolder/file.js|2|0|4|FizBuz function that generates fiz or buz or fizbuz\n./testfolder/file.js|2|0|4|FizBuz function that generates fiz or buz or fizbuz</Example Ouput>"'
    vim.system({'claude', '--model', 'claude-haiku-4-5', '--tools', 'Bash,Read(./*)', '--disable-slash-commands', '--no-session-persistence', '--system-prompt', system_prompt, '-p', context.prompt},{text=true},function(obj) resolve(obj.stdout) end)
  end)
end)
```

![100Search](https://github.com/user-attachments/assets/5166a132-fdc3-49bf-9a1a-5d88fd761352)

#### create_window_query
This function enables direct communication with an AI agent without modifying the currently opened buffer.

```lua
vim.keymap.set("n", "<leader>aiq", function()
  require("100").create_window_query({}, function (context, resolve, reject)
    local system_prompt = 'You are a coding agent that never asks questions, explains output or generates markdown. Your only job is to answer queries using the given prompt\n## rules\n- you never ask questions\n- if you do not have enough information to answer the users query sufficiently, then dont ask follow up questions. Instead form assumptions and aswer the query based upon that'
    local prompt = string.format("<prompt>\n%s\n</prompt>", context.prompt)
    vim.system({'claude', '--model', 'claude-haiku-4-5', '--tools', '', '--disable-slash-commands', '--no-session-persistence', '--system-prompt', system_prompt, '-p', prompt},{text=true},function(obj) resolve(obj.stdout) end)
  end)
end)
```

![100Query](https://github.com/user-attachments/assets/d05621d0-1944-4e01-974c-886a2836b35a)

#### create_window_explain
This function allows the user to ask questions about the currently selected text under the cursor. (only usable in visual mode)

```lua
vim.keymap.set("v", "<leader>aie", function()
  require("100").create_window_explain({}, function (context, resolve, reject)
    local system_prompt = 'Given a specific prompt, you are responsible for explaining a selection of code.'
    local prompt = string.format("<prompt>\n%s\n</prompt>\n<selection_content>\n%s\n</selection_content>", context.prompt, context.selection)
    vim.system({'claude', '--model', 'claude-haiku-4-5', '--tools', '', '--disable-slash-commands', '--no-session-persistence', '--system-prompt', system_prompt, '-p', prompt},{text=true},function(obj) resolve(obj.stdout) end)
  end)
end)
```

![100Explain](https://github.com/user-attachments/assets/0725c9f7-ac87-4152-9aef-1b114c6f3dfc)

#### create_window_insert
This function allows the user to insert text/code generated by the AI agent below the cursor. (only usable in normal mode)

```lua
vim.keymap.set("n", "<leader>aii", function()
  require("100").create_window_insert({}, function (context, resolve, reject)
    local system_prompt = 'You are a code generator that never asks questions, explains output or generates markdown.\n## code style\n- you only respond with code\n- your responses never contain markdown.\n- your responses never start with ```'
    local prompt = string.format("you receive a prompt/notes in neovim for which you need to generate code. incorporate the prompt/notes every time.\n<prompt>\n%s\n</prompt>", context.prompt)
    vim.system({'claude', '--model', 'claude-haiku-4-5', '--tools', '', '--disable-slash-commands', '--no-session-persistence', '--system-prompt', system_prompt, '-p', prompt},{text=true},function(obj) resolve(obj.stdout) end)
  end)
end)
```

![100Insert](https://github.com/user-attachments/assets/89a118b8-fe4e-4c5a-a878-ac4fa33a8991)

#### create_window_replace
This function allows the user to replace selected text/code under the cursor with text/code generated by the AI agent. (only usable in visual mode)

```lua
vim.keymap.set("v", "<leader>air", function()
  require("100").create_window_replace({}, function (context, resolve, reject)
    local system_prompt = 'You are a code generator that never asks questions, explains output or generates markdown.\n## code style\n- you only respond with code\n- your responses never contain markdown.\n- your responses never start with ```'
    local prompt = string.format("you receive a selection in neovim that you need to replace with new code. the selection's contents may contain notes, incorporate the notes every time if there are any. consider the context of the selection and what you are suppose to be implementing. pay attention to the indentation inside of the selection and never use markdown.\n<notes>\n%s\n</notes>\n<selection_content>\n%s\n</selection_content>", context.prompt, context.selection)
    vim.system({'claude', '--model', 'claude-haiku-4-5', '--tools', '', '--disable-slash-commands', '--no-session-persistence', '--system-prompt', system_prompt, '-p', prompt},{text=true},function(obj) resolve(obj.stdout) end)
  end)
end)
```

![100Replace](https://github.com/user-attachments/assets/d7d45f7d-3a25-4c37-8f79-158d207563e6)

## Prompting strategies
To effectively utilize AI in a professional setting, you will require consistent and predictable results. Current AI solutions and models, however, sometimes struggle with this type of task. This difficulty stems from confusion and misinterpretation. For this reason, to achieve the best results, it is generally recommended to always provide a plain-text example of how the AI agent should respond. An example of this strategy can be observed in the examples above.

## Up and coming features:
- better callback context (currently very rudimentary)
- reject callback support (currently has no effect)
- create_window_query_cwd (combination between `create_window_search` and `create_window_query` allowing for queries concerning project structure. I'm very much aware that this feature can however just be implemented using `create_window_query` at the current moment.)

## Noteworthy mentions:
- Praise where praise is due, I cannot in good faith take full credit for the ai workflow this project demonstrates and enables. This achievement belongs to `ThePrimeagen`.

