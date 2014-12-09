(require 'julia-mode)

(defcustom julia-repl-executable
  "julia"
  "Path to the Julia CLI."
  :group 'julia-mode)

(defvar julia-repl-buffer nil
  "Stores the name of the current Julia REPL buffer, or nil.")

(defun run-julia (cmd &optional dont-switch-p)
  "Run REPL process, input and output via buffer '*julia-repl*'"
  (interactive (list (if current-prefix-arg
			 (read-string "Run julia REPL:" julia-repl-executable)
		       julia-repl-executable)))
  (unless (comint-check-proc "*julia-repl*")
    (save-excursion (let ((cmdlist (split-string cmd)))
		      (set-buffer (apply 'make-comint "julia-repl" (car cmdlist)
					 nil (cdr cmdlist)))
		      (julia-repl-mode))))
  (setq julia-repl-executable cmd)
  (setq julia-repl-buffer "*julia-repl*")
  (unless dont-switch-p
    (pop-to-buffer "*julia-repl*")))

(defun julia-send-region (start end)
  "Send the current region to the inferior julia process.
START and END define region within current buffer"
  (interactive "r")
  (julia-mode-run-repl julia-repl-executable t)
  (comint-send-region julia-repl-buffer start end)
  (comint-send-string julia-repl-buffer "\n"))

(defun julia-send-buffer ()
  "Send the buffer to the Julia REPL process."
  (interactive)
  (julia-mode-send-region (point-min) (point-max)))

(defun kill-julia ()
  (interactive)
  (when (comint-check-proc julia-repl-buffer)
    (with-current-buffer julia-repl-buffer
      (comint-kill-subjob))))

(define-derived-mode julia-repl-mode comint-mode "Julia REPL")

(provide 'julia-repl-mode)
