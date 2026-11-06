local tu = require('tests.utils')

local PATH = './tests/sample/index.qml'
local LANG = 'qml'

local data_for_join = {
  {
    path = PATH,
    mode = 'join',
    lang = LANG,
    desc = 'lang "%s", node "ui_object_initializer", custom preset',
    cursor = { 10, 10 },
    expected = { 7, 7 },
    result = { 7, 7 },
  },
  {
    path = PATH,
    mode = 'join',
    lang = LANG,
    desc = 'lang "%s", node "array", preset default',
    cursor = { 20, 25 },
    result = { 17, 17 },
    expected = { 17, 17 },
  },
  {
    path = PATH,
    mode = 'join',
    lang = LANG,
    desc = 'lang "%s", node "function_declaration", preset default',
    cursor = { 31, 8 },
    expected = { 27, 27 },
    result = { 27, 27 },
  },
  {
    path = PATH,
    mode = 'join',
    lang = LANG,
    desc = 'lang "%s", node "statement_block", custom preset',
    cursor = { 39, 7 },
    expected = { 35, 35 },
    result = { 35, 35 },
  },
  {
    path = PATH,
    mode = 'join',
    lang = LANG,
    desc = 'lang "%s", node "statement_block" , more complicated, custom preset',
    cursor = { 51, 14 },
    expected = { 48, 48 },
    result = { 48, 48 },
  },
}

local treesj = require('treesj')
local opts = {}
treesj.setup(opts)

describe('TreeSJ JOIN:', function()
  for _, value in ipairs(data_for_join) do
    tu._test_format(value, treesj)
  end
end)
