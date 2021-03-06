(defun make-task (name when)
  (interactive "sTask name \nsWhen to finish ")
  (move-end-of-line nil)
  (insert (format "\n- %s (%s)\n" name when))
  (task-head))

(defun mark-done ()
  (interactive)
  (move-end-of-line nil)
  (insert "  ✓")
  (task-head))

(defun mark-undone ()
  (interactive)
  (let ((line (thing-at-point 'line t)))
    (let ((replaced-line (replace-regexp-in-string "✓" "" line nil 'literal)))
      (kill-whole-line)
      (insert replaced-line))
    (task-head)))

(defun get-tasks (text)
  (let ((lines (split-string text "\n"))
	(tasks nil))
    (dolist (line lines)
      (when (string-match "^- .+" line)
	(push line tasks)))
    tasks))

(defun get-tasks-by-status (tasks)
  (let ((done-tasks nil)
	(not-done-tasks nil))
    (dolist (task tasks)
      (if (string-match "✓" task)
	  (push task done-tasks)
	(push task not-done-tasks)))
    (list done-tasks not-done-tasks)))

(defun get-task-stats ()
  (let* ((tasks (get-tasks (buffer-string)))
	 (task-status (get-tasks-by-status tasks)))
    (list (cons 'total (length tasks))
	  (cons 'done (length (first task-status)))
	  (cons 'pending (length (second task-status))))))

(defun task-head ()
  (interactive)
  (let ((stats (get-task-stats)))
    (goto-char (point-min))
    (let ((first-line (thing-at-point 'line)))
      (when (string-match "^\]\]" first-line)
	(kill-whole-line)))
    (insert
     (format "]] Total: %s, done: %s, pening: %s\n"
	     (cdr (assoc 'total stats))
	     (cdr (assoc 'done stats))
	     (cdr (assoc 'pending stats))))))


