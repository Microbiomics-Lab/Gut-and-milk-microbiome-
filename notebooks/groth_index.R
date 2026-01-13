# This code represent the information for `groth index`

xyplot(g_index ~ age_d | sex,
       data = df,
       groups = p_code,
       type = c("p", "a"),
       panel = function(x, y, ...) {
           panel.xyplot(x, y, ...)
           panel.lmline(x, y, col = "black", lwd = 2, lty = 1)
       },
       key = list(
           space = "top",
           columns = 2,
           text = list(c("Overall Regression by Sex", "By Person")),
           lines = list(col = c("black", "transparent"), lty = 1, lwd = 2),
           points = list(pch = 1, col = c("transparent", "orange"))
       ),
    xlab = "Age in Days",
    ylab = "Patient Growth Index"
)