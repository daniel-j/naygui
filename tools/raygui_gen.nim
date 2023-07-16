import common, std/[strutils, streams]
when defined(nimPreviewSlimSystem):
  import std/syncio

const
  raymathHeader = """
from raylib import Vector2, Vector3, Color, Rectangle, Texture2D, Image, GlyphInfo, Font
export Vector2, Vector3, Color, Rectangle, Texture2D, Image, GlyphInfo, Font
"""
  excludedTypes = [
    "Vector2",
    "Vector3",
    "Color",
    "Rectangle",
    "Texture2D",
    "Image",
    "GlyphInfo",
    "Font"
  ]

proc genBindings(t: TopLevel, fname: string, header, footer: string) =
  var buf = newStringOfCap(50)
  var indent = 0
  var otp: FileStream
  try:
    otp = openFileStream(fname, fmWrite)
    lit header
    # Generate type definitions
    lit "\ntype"
    scope:
      for obj in items(t.structs):
        if obj.name in excludedTypes: continue
        spaces
        ident capitalizeAscii(obj.name)
        lit "* {.bycopy.} = object"
        doc obj
        scope:
          for fld in items(obj.fields):
            spaces
            var name = fld.name
            ident name
            lit "*: "
            # let kind = getReplacement(obj.name, name, replacement)
            # if kind != "":
            #   lit kind
            #   continue
            var baseKind = ""
            let kind = convertType(fld.`type`, "", false, false, baseKind)
            lit kind
            doc fld
        lit "\n"
    # Generate functions
    lit "\n{.push callconv: cdecl, header: \"raygui.h\".}"
    for fnc in items(t.functions):
      lit "\nproc "
      var name = fnc.name
      if name.endsWith("Pro") or name.endsWith("Ex"):
        removeSuffix(name, "Ex")
        removeSuffix(name, "Pro")
      ident uncapitalizeAscii(name)
      lit "*("
      var hasVarargs = false
      for i, param in fnc.params.pairs:
        if param.name == "args" and param.`type` == "...":
          hasVarargs = true
        else:
          if i > 0: lit ", "
          ident param.name
          lit ": "
          var baseKind = ""
          let kind = convertType(param.`type`, "", false, true, baseKind)
          lit kind
      lit ")"
      if fnc.returnType != "void":
        lit ": "
        var baseKind = ""
        let kind = convertType(fnc.returnType, "", false, true, baseKind)
        lit kind
      lit " {.importc: \""
      ident fnc.name
      lit "\""
      if hasVarargs:
        lit ", varargs"
      lit ".}"
      if fnc.description != "":
        scope:
          spaces
          lit "## "
          lit fnc.description
    lit "\n"
    lit footer
  finally:
    if otp != nil: otp.close()

const
  raymathApi = "../api/raygui.json"
  outputname = "../src/raygui.nim"

proc main =
  var t = parseApi(raymathApi)
  genBindings(t, outputname, raymathHeader, "")

main()
