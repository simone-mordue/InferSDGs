app <- ShinyDriver$new("../../")
app$snapshotInit("mytest2")

app$uploadFile(upload = "poverty.pdf") # <-- This should be the path to the file, relative to the app's tests/shinytest directory
app$snapshot()
