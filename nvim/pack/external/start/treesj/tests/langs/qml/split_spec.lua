local tu = require('tests.utils')

local PATH = './tests/sample/index.qml'
local LANG = 'qml'

local data_for_split = {
  {
    path = PATH,
    mode = 'split',
    lang = LANG,
    desc = 'lang "%s", node "ui_object_initializer", custom preset',
    cursor = { 7, 9 },
    expected = { 10, 14 },
    result = { 10, 14 },
  },
  {
    path = PATH,
    mode = 'split',
    lang = LANG,
    desc = 'lang "%s", node "array", preset default',
    cursor = { 17, 25 },
    expected = { 20, 24 },
    result = { 20, 24 },
  },
  {
    path = PATH,
    mode = 'split',
    lang = LANG,
    desc = 'lang "%s", node "function_declaration", preset default',
    cursor = { 27, 41 },
    expected = { 30, 32 },
    result = { 30, 32 },
  },
  {
    path = PATH,
    mode = 'join',
    lang = LANG,
    desc = 'lang "%s", node "statement_block", custom preset',
    cursor = { 35, 36 },
    expected = { 38, 44 },
    result = { 38, 44 },
  },
  {
    path = PATH,
    mode = 'join',
    lang = LANG,
    desc = 'lang "%s", node "statement_block" , more complicated, custom preset',
    cursor = { 47, 14 },
    expected = { 47, 64 },
    result = { 47, 64 },
  },
}

local treesj = require('treesj')
local opts = {}
treesj.setup(opts)

describe('TreeSJ SPLIT:', function()
  for _, value in ipairs(data_for_split) do
    tu._test_format(value, treesj)
  end
end)
