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



**Changelog documentation in NAT,** v1.1b, date of changes: **15/04/2013**

All changes are preceeded by &quot;% -- changelog v1.1b ##### (start) // 20130415&quot; and ended by &quot;% -- changelog v1.1b ##### (end) // 20130415&quot;

**File changed:**  **network\_load.m**

- --Added transformers into analysis in order to test if they are overloaded
- --Changed NAT-data structure with the following changes:
  - data\_o.Grid.Branches.id is now separated into transformer and line data: data\_o.Grid.Branches.line\_ids and data\_o.Grid.Branches\_tran\_ids
  - Objects for lines and transformers are separated in the data\_o.Grid.Branches.Lines and data\_o.Grid.Branches.Transf
- --Added two lines where branch limits (lines, two-winding transformers) are defined. Used a function within branch.m class (define\_branch\_limits).
  - All above changes in lines 75-92 and line 98-106

**File changed:**  **branch.m**

- --Defined Rated\_Voltage1\_phase\_phase and Rated\_Voltage1\_phase\_earth (from node), Rated\_Voltage2\_phase\_phase and Rated\_Voltage2\_phase\_earth, Current\_Limits, App\_Power\_Limits
- --Modified Branch function to read rated voltages for lines and transformers
  - function obj = Branch(sin\_ext, branch\_id\_ext)
- --Added function to define branch limits (current and apparent power limits) for lines and transformers. The function checks for all possible limit values from SINCAL
  - function current\_limits = define\_branch\_limits (obj)
- --Added function that reads active, reactive and apparent power load-flow results for unsymmetrical calculations
  - function power = update\_power\_branch\_LF\_USYM (obj)
- --All above changes in lines 1-304

**File changed:**  **Connection\_Point.m**

- --Modified the way load values are saved into SINCAL model (bug? Where L123 loads are not updated with single phase values) – the fix I used is to sum all phases and write the value into &#39;P&#39; and &#39;Q&#39; field.
  - Possibility of adding a subfunction that checks the load type
  - Line 156: obj\_s(i).P\_Q\_Obj.set(&#39;Item&#39;,&#39;P&#39;,p\_q(1)+p\_q(3)+p\_q(5));
  - Line 157: obj\_s(i).P\_Q\_Obj.set(&#39;Item&#39;,&#39;Q&#39;,p\_q(2)+p\_q(4)+p\_q(6));

**File changed:**  **Connection\_All\_Point.m**

- --Fixed a bug where voltage level search did not work due to untrimmed node names
- --Bug fix in lines 73-86

**Changed name of on-line function**  **on\_line\_voltage\_analysis.m**  **to**  **online\_voltage\_analysis.m**

**Added on-line function**  **online\_branch\_violation\_analysis.m**

- --The function checks branch (line, two winding transformers) limit violations. SINCAL offers 4 limit values per element, so the function is capable of checking all limits
- --I added several possible operating conditions:
  - If the model will experience on-line thermal limit changes (smart grids), the function can recheck the branch limits for each branch at every iteration.
    - Currently this is disabled, it only checks the values once.
  - All branch currents/apparent power is compared to the maximum/thermal limits
    - If more than one branch limit is defined, all branch limits are checked, if only one limit is defined, only one is checked (for increased speed of calculation?).
    - The results return conditional values of 0 (branch limits not exceeded), 1 (branch limits exceeded at base level), 2 (branch limits exceeded at first thermal/maximum limit), 3 (branch limits exceeded at second thermal/maximum limit) and 4 (branch limits exceeded at third thermal/maximum limit)
  - Branch values can also be stored as SI units for each phase or not at all (to be discussed). The result of the branch values are given in a n x 16 array (P,Q,S,I) for L1,L2,L3 and LE.
- --Currently, the NR symmetrical load flow branch violation checking is not working, as I have yet to convince the program to use LF\_NR setting for the calculation method.
  - Line 130 of network calculation.m: nline\_branch\_violation\_analysis(handles)

**Changelog documentation in NAT,** v1.1b, date of changes: **18/04/2013**

All changes are preceeded by &quot;% -- changelog v1.1b ##### (start) // 20130418&quot; and ended by &quot;% -- changelog v1.1b ##### (end) // 20130418&quot;

**File changed:**  **network\_load.m**

**Changelog documentation in NAT,** v1.1b, date of changes: **18/04/2013**