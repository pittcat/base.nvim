describe("log2debug", function()
  local dbg
  
  before_each(function()
    -- 清理之前的调试上下文
    package.loaded['base.log2debug'] = nil
    dbg = require('base.log2debug')
    dbg.clear()
  end)
  
  after_each(function()
    dbg.clear()
  end)
  
  describe("basic logging", function()
    it("should log debug messages", function()
      assert.has_no.errors(function()
        dbg.debug("Test debug message")
        dbg.info("Test info message")
        dbg.warn("Test warning message")
      end)
    end)
    
    it("should log with data", function()
      assert.has_no.errors(function()
        dbg.debug("Test with data", { key = "value", number = 42 })
      end)
    end)
  end)
  
  describe("context management", function()
    it("should create and end context", function()
      assert.has_no.errors(function()
        dbg.begin("test_context")
        dbg.log("Inside context")
        dbg.done()
      end)
    end)
    
    it("should handle missing context gracefully", function()
      assert.has_no.errors(function()
        dbg.done() -- No active context
      end)
    end)
    
    it("should log without context", function()
      assert.has_no.errors(function()
        dbg.log("No context message")
      end)
    end)
  end)
  
  describe("function tracing", function()
    it("should trace function calls", function()
      assert.has_no.errors(function()
        dbg.fn_call("test_function", "arg1", 123, { key = "value" })
        dbg.fn_return("test_function", "result", true)
      end)
    end)
    
    it("should wrap functions", function()
      local function add(a, b)
        return a + b
      end
      
      local wrapped = dbg.wrap(add, "add")
      local result = wrapped(5, 3)
      assert.equals(8, result)
    end)
    
    it("should wrap functions with multiple returns", function()
      local function multi_return(a, b)
        return a + b, a * b
      end
      
      local wrapped = dbg.wrap(multi_return, "multi_return")
      local sum, product = wrapped(4, 5)
      assert.equals(9, sum)
      assert.equals(20, product)
    end)
  end)
  
  describe("checkpoints", function()
    it("should record checkpoints", function()
      assert.has_no.errors(function()
        dbg.checkpoint("start")
        dbg.checkpoint("middle", { progress = 50 })
        dbg.checkpoint("end")
      end)
    end)
  end)
  
  describe("assertions", function()
    it("should pass valid assertions", function()
      assert.has_no.errors(function()
        dbg.assert(true, "This should pass")
        dbg.assert(1 == 1, "Math works")
        dbg.assert("string", "Truthy value")
      end)
    end)
    
    it("should fail invalid assertions", function()
      assert.has_error(function()
        dbg.assert(false, "This should fail")
      end, "This should fail")
    end)
    
    it("should support data in assertions", function()
      assert.has_no.errors(function()
        dbg.assert(true, "With data", { test = "data" })
      end)
    end)
  end)
  
  describe("scoped debugging", function()
    it("should execute function in scope", function()
      local result = dbg.scope("test_scope", function()
        dbg.log("Inside scope")
        return "success"
      end)
      assert.equals("success", result)
    end)
    
    it("should handle errors in scope", function()
      assert.has_error(function()
        dbg.scope("error_scope", function()
          error("Test error")
        end)
      end)
    end)
  end)
  
  describe("debug reports", function()
    it("should generate reports", function()
      dbg.begin("report_test")
      dbg.log("Step 1")
      dbg.log("Step 2")
      dbg.done()
      
      local report = dbg.report("report_test")
      assert.is_not_nil(report)
      assert.is_not_nil(report.start_time)
      assert.is_table(report.logs)
      assert.equals(2, #report.logs)
    end)
    
    it("should return all contexts when no context specified", function()
      dbg.begin("ctx1")
      dbg.log("Context 1")
      dbg.done()
      
      dbg.begin("ctx2")
      dbg.log("Context 2")
      dbg.done()
      
      local all_reports = dbg.report()
      assert.is_table(all_reports)
      assert.is_not_nil(all_reports.ctx1)
      assert.is_not_nil(all_reports.ctx2)
    end)
  end)
  
  describe("clear functionality", function()
    it("should clear all contexts", function()
      dbg.begin("to_clear")
      dbg.log("Will be cleared")
      dbg.done()
      
      dbg.clear()
      
      local report = dbg.report()
      assert.same({}, report)
    end)
  end)
end)