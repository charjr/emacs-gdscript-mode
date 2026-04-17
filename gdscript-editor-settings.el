;;; gdscript-editor-settings.el --- Determines Godot engine config  -*- lexical-binding: t; -*-

;; Copyright (C) 2020-2026 GDQuest and contributors

;; Author: John Charman <johnrcharman@gmail.com>
;; Maintainer: Jen-Chieh Shen <jcs090218@gmail.com>

;; This file is not part of GNU Emacs.

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

;; This package contains commands to retrieve Godot editor settings.

;;; Code:

(require 'gdscript-godot)
(require 'gdscript-customization)

(defun gdscript-editor-settings (version)
  "Returns a list of relevant Godot editor settings.

For Godot 3.X, VERSION should be '3'.
For Godot 4.0.X, VERSION should be '4'.
For Godot 4.1 onwards, VERSION is the '4.1', '4.2', etc."
  (if (assoc version gdscript-editor-settings--cache)
      (print "reusing cache"))
  (unless (assoc version gdscript-editor-settings--cache)
    (with-temp-buffer
      (insert-file-contents (gdscript-editor-settings--find-tres version))
      (keep-lines "text_editor/\\(behavior/indent\\|completion/add_type_hints\\)")
      (let ((settings '()))
        (unless (equal gdscript-use-tab-indents 'ignore)
	  (add-to-list
           'settings
           `(indent-tabs-mode ,(if (equal gdscript-use-tab-indents 'auto)
				   (gdscript-editor-settings--indent-type)
                                 (gdscript-use-tab-indents)))))
        (unless (equal gdscript-tab-width 'ignore)
	  (add-to-list
           'settings
           `(tab-width ,(if (equal gdscript-tab-width 'auto)
                            (gdscript-editor-settings--indent-size)
                          (gdscript-tab-width)))))
        (add-to-list
         'settings
         `(gdscript-use-type-hints ,(if (equal gdscript-use-type-hints 'auto)
				        (gdscript-editor-settings--type-hints)
				      (gdscript-use-type-hints))))
        (push `(,version . ,settings) gdscript-editor-settings--cache ))))
  (cdr (assoc version gdscript-editor-settings--cache)))

(defun gdscript-editor-settings-refresh ()
  "Clear settings cache"
  (setq gdscript-editor-settings--cache '()))

(defvar gdscript-editor-settings--cache '()
  "Internal cache for precomputed Godot editor settings.

This should not be accessed outside of `gdscript-editor-settings'.")

(defun gdscript-editor-settings--find-tres (version)
  "Finds Godot editor settings for the given version.

For Godot 3.X, VERSION should be '3'.
For Godot 4.0.X, VERSION should be '4'.
For Godot 4.1 onwards, VERSION is the '4.1', '4.2', etc."
  (file-name-concat (gdscript-editor-settings--find-config)
                    (format "editor_settings-%s.tres" version)))

(defun gdscript-editor-settings--find-config ()
  "Finds the Godot editor's config directory.

This will return the `gdscript-godot-config-dir', if non-nil.
Otherwise, it will search conventional locations based on the OS."
  (expand-file-name
   (if gdscript-godot-config-dir gdscript-godot-config-dir
     (pcase system-type
       ('darwin "~/Library/Application Support/Godot/")
       ('windows-nt (file-name-concat (getenv "APPDATA") "Godot"))
       ('gnu/linux (file-name-concat (or (getenv "XDG_CONFIG_HOME")
                                         "~/.config")
                                     "godot"))))))

(defun gdscript-editor-settings--indent-type ()
  "Determines the indent type used by Godot editor.

This returns t for tabs, or nil for spaces.

This must be called within a buffer containing the text of a Godot editor settings resource."
  (goto-char (point-min))
  (if (search-forward "text_editor/behavior/indent/type = 1" nil t)
      nil
    t))

(defun gdscript-editor-settings--indent-size ()
  "Determines the indent size used by Godot editor.

This must be called within a buffer containing the text of a Godot editor settings resource."
  (goto-char (point-min))
  (if (re-search-forward "text_editor/behavior/indent/size = \\([0-9]+\\)" nil t)
      (string-to-number (match-string 1))
    4))

(defun gdscript-editor-settings--type-hints ()
  "Determines if the Godot editor adds type hints during completion.

This must be called within a buffer containing the text of a Godot editor settings resource."
  (goto-char (point-min))
  (if (search-forward "text_editor/completion/add_type_hints = false" nil t)
      nil
    t))

(provide 'gdscript-editor-settings)
;;; gdscript-editor-settings.el ends here
