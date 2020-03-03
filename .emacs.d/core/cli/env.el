;;; core/cli/env.el -*- lexical-binding: t; -*-

(defcli! env (&rest args)
  "Creates or regenerates your envvars file.

  doom env [-c|--clear]

This is meant to be a faster and more comprehensive alternative to
exec-path-from-shell. See the FAQ in the documentation for an explanation why.

The envvars file is created by scraping your (interactive) shell environment
into newline-delimited KEY=VALUE pairs. Typically by running '$SHELL -ic env'
(or '$SHELL -c set' on windows). Doom loads this file at startup (if it exists)
to ensure Emacs mirrors your shell environment (particularly to ensure PATH and
SHELL are correctly set).

This is useful in cases where you cannot guarantee that Emacs (or the daemon)
will be launched from the correct environment (e.g. on MacOS or through certain
app launchers on Linux).

This file is automatically regenerated when you run this command or 'doom
refresh'. However, 'doom refresh' will only regenerate this file if it exists.

Use the -c or --clear switch to delete your envvar file."
  (when (member "clear" args)  ; DEPRECATED
    (message "'doom env clear' is deprecated. Use 'doom env -c' or 'doom env --clear' instead")
    (push "-c" args))
  (let ((env-file (or (cadr (member "-o" args))
                      doom-env-file)))
    (cond ((or (member "-c" args)
               (member "--clear" args))
           (unless (file-exists-p env-file)
             (user-error! "%S does not exist to be cleared"
                          (path env-file)))
           (delete-file env-file)
           (print! (success "Successfully deleted %S")
                   (path env-file)))

          ((or (null args)
               (member "-o" args))
           (doom-reload-env-file 'force env-file))

          ((user-error "I don't understand 'doom env %s'"
                       (string-join args " "))))))


;;
;; Helpers

(defvar doom-env-ignored-vars
  '("^PWD$"
    "^PS1$"
    "^R?PROMPT$"
    "^DBUS_SESSION_BUS_ADDRESS$"
    "^GPG_AGENT_INFO$"
    "^SSH_AGENT_PID$"
    "^SSH_AUTH_SOCK$"
    ;; Doom envvars
    "^INSECURE$"
    "^DEBUG$"
    "^YES$"
    "^__")
  "Environment variables to not save in `doom-env-file'.

Each string is a regexp, matched against variable names to omit from
`doom-env-file'.")

(defvar doom-env-executable
  (if IS-WINDOWS
      "set"
    (executable-find "env"))
  "The program to use to scrape your shell environment with.
It is rare that you'll need to change this.")

(defvar doom-env-switches
  (if IS-WINDOWS
      "-c"
    "-ic") ; Execute in an interactive shell
  "The `shell-command-switch'es to use on `doom-env-executable'.
This is a list of strings. Each entry is run separately and in sequence with
`doom-env-executable' to scrape envvars from your shell environment.")

(defun doom-reload-env-file (&optional force-p env-file)
  "Generates `doom-env-file', if it doesn't exist (or if FORCE-P).

This scrapes the variables from your shell environment by running
`doom-env-executable' through `shell-file-name' with `doom-env-switches'. By
default, on Linux, this is '$SHELL -ic /usr/bin/env'. Variables in
`doom-env-ignored-vars' are removed."
  (let ((env-file (if env-file
                      (expand-file-name env-file)
                    doom-env-file)))
    (when (or force-p (not (file-exists-p env-file)))
      (with-temp-file env-file
        (print! (start "%s envvars file at %S")
                (if (file-exists-p env-file)
                    "Regenerating"
                  "Generating")
                (path env-file))
        (let ((process-environment doom--initial-process-environment))
          (let ((shell-command-switch doom-env-switches)
                (error-buffer (get-buffer-create "*env errors*")))
            (print! (info "Scraping shell environment with '%s %s %s'")
                    (filename shell-file-name)
                    shell-command-switch
                    (filename doom-env-executable))
            (save-excursion
              (shell-command doom-env-executable (current-buffer) error-buffer))
            (print-group!
             (let ((errors (with-current-buffer error-buffer (buffer-string))))
               (unless (string-empty-p errors)
                 (print! (info "Error output:\n\n%s") (indent 4 errors))))
             ;; Remove undesireable variables
             (insert
              (concat
               "# -*- mode: dotenv -*-\n"
               (format "# Generated with: %s %s %s\n"
                       shell-file-name
                       doom-env-switches
                       doom-env-executable)
               "# ---------------------------------------------------------------------------\n"
               "# This file was auto-generated by `doom env'. It contains a list of environment\n"
               "# variables scraped from your default shell (excluding variables blacklisted\n"
               "# in doom-env-ignored-vars).\n"
               "#\n"
               "# It is NOT safe to edit this file. Changes will be overwritten next time that\n"
               "# `doom refresh` is executed. Alternatively, create your own env file with\n"
               "# `doom env -o ~/.doom.d/myenv`, then load it with (doom-load-envvars-file FILE)\n"
               "# in your private config.el.\n"
               "# ---------------------------------------------------------------------------\n\n"))
             (goto-char (point-min))
             (while (re-search-forward "\n\\([^= \n]+\\)=" nil t)
               (save-excursion
                 (let* ((valend (or (save-match-data
                                      (when (re-search-forward "^\\([^= ]+\\)=" nil t)
                                        (line-beginning-position)))
                                    (point-max)))
                        (var (match-string 1)))
                   (when (cl-loop for regexp in doom-env-ignored-vars
                                  if (string-match-p regexp var)
                                  return t)
                     (print! (info "Ignoring %s") var)
                     (delete-region (match-beginning 0) (1- valend)))))))
            (print! (success "Successfully generated %S")
                    (path env-file))
            t))))))
