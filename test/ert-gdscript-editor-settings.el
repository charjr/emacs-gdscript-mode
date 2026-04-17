;;; ert-gdscript-editor-settings.el --- unit tests  -*- lexical-binding: t; -*-

;; Copyright (C) 2020-2026 GDQuest and contributors

;; Author: John <johnrcharman@gmail.com>
;; Maintainer: Jen-Chieh Shen <jcs090218@gmail.com>

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; 

;;; Code:

(require 'ert)
(require 'gdscript-editor-settings)

;; Parsing Type Hints ----------------------------------------------------------

;; Defaults

(ert-deftest gdscript-editor-settings-format-2-parse-typehint-default ()
  "Determining default typehint in format 2, a.k.a. Godot 3.y.z.

Godot omits defaults when set through the editor.
In Godot 3.y.z; typehints are disabled by default."
  (with-temp-buffer
    (should (equal nil (gdscript-editor-settings--type-hints)))))

(ert-deftest gdscript-editor-settings-format-3-parse-typehint-default ()
  "Determining default typehint in format 3, a.k.a. Godot 4.y.z.

Godot omits defaults when set through the editor.
In Godot 4.y.z; typehints are enabled by default."
  (with-temp-buffer
    (should (equal t (gdscript-editor-settings--type-hints)))))

;; Non-defaults

(ert-deftest gdscript-editor-settings-format-2-parse-typehints-non-default ()
  "Determining default typehint in format 2, a.k.a. Godot 3.y.z.

In Godot 3.y.z; the non-default is to enable typehints."
  (with-temp-buffer
    (insert "text_editor/completion/add_type_hints = true")
    (should (equal t (gdscript-editor-settings--type-hints)))))

(ert-deftest gdscript-editor-settings-format-3-parse-typehints-non-default ()
  "Determining default typehint in format 3, a.k.a. Godot 4.y.z.

In Godot 4.y.z; the non-default is to disable typehints."
  (with-temp-buffer
    (insert "text_editor/completion/add_type_hints = false")
    (should (equal nil (gdscript-editor-settings--type-hints)))))




;;; test-gdscript-editor-settings.el ends here
