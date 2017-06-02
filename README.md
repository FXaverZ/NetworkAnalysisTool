# NetworkAnalysisTool

##Changelog
**Changelog documentation in NAT,** v1.1b, date of changes: **11/04/2013**

All changes are preceeded by &quot;% -- changelog v1.1b ##### (start) // 20130411&quot; and ended by &quot;% -- changelog v1.1b ##### (end) // 20130411&quot;

**File changed:**  **network\_load.m**

- --Added a table with all nodes in system in SINCAL.Tables.Node
- --Added a table with all voltage levels in system in SINCAL.Tables.VoltageLevel
  - Line 30: sin.table\_data\_load(&#39;Node&#39;);
  - Line 31: sin.table\_data\_load(&#39;VoltageLevel&#39;);

- --Copied the table to NAT\_Data\_class.Grid.All\_Node.ids
  - Line 45-47: data\_o.Grid.All\_Node.ids =…
- --Added a all node class Connection\_All\_Point
  - Line 62 – 68: data\_o.Grid.All\_Node.Points
  - Used a method to define voltage limits for all nodes, line 67

- -- **Added a class**** Connection\_All\_Points.m**
- --File similar to Connection\_Points.m, except it checks all nodes regardless of load connected
  - Used in NAT\_data\_class.Grid.All\_Node.Points &lt;Connection\_All\_Points object&gt;
  - Object includes (Node\_ID, Node\_Obj, Node\_Name, VoltLevel\_ID, Rated\_Voltage\_phase\_phase, Rated\_Voltage\_phase\_earth, Voltage\_Limits and Voltage&gt;
- --Defined all nodes, matched voltage levels with nodes to define actual voltage level (bug in SINCAL?) and defined rated voltages for phase-phase and phase-earth
  - function obj = Connection\_All\_Point(sin\_ext, node\_id\_ext)
- --Defined voltage limits for all nodes, default values at 90 % and 110 % if none specified in model.  Can observe two voltage limit levels
  - function voltage\_limits = define\_voltage\_limits (obj)
- --Update voltage node for unsymmetric and symmetric load flows (same as Connection\_Point class)
  - function voltage = update\_voltage\_node\_LF\_USYM (obj)
  - function voltage = update\_voltages\_node\_LF\_NR (obj)

**Added on-line function**  **on\_line\_voltage\_analysis.m**

- --Ex-Analyzing\_function1. The function checks voltage violations for two voltage limit levels.
- --I added several possible operating conditions:
  - If the model will experience on-line voltage-limit changes (smart grids?), the function can recheck the voltage limits for each node at every iteration.
    - Currently this is disabled, it only checks the values once.
  - All nodal voltages are compared to voltage limits
    - If two voltage limit levels are defined, both are checked, if only one voltage limit level is defined, only one is checked.
    - The results return conditional values of 0 (voltage limits not exceeded), 1 (voltage limits exceeded at first limit level) and 2 (voltage limits exceeded at second limit level)
  - Voltages can also be stored either as V or in % for each phase or not at all (to be discussed)
- --Currently, the NR symmetrical load flow voltage checking is not working, as I have yet to convince the program to use LF\_NR setting for the calculation method.

**File changed:**  **network\_calculation.m**

- --File changed to properly call the on-line voltage violation check function.
  - Line 126: on\_line\_voltage\_analysis(handles); %%CH\_MA