local autoclose_status, autoclose = pcall(require, "autoclose")
if not autoclose_status then
  return
end

autoclose.setup()
