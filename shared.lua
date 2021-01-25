function string.removeHex( s )
  if type (s) == "string" then
      while (s ~= s:gsub ("#%x%x%x%x%x%x", "")) do
          s = s:gsub ("#%x%x%x%x%x%x", "")
      end
  end
  return s or false
end

function switch(t)
  t.case = function (self, x, ...)
		local f=self.default
		if not f then
			return
		end
		f(x, ...)
  end
  return t
end