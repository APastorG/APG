/***************************************************************************************************
/
/  Author:     Antonio Pastor González
/  ¯¯¯¯¯¯
/
/  Date:       
/  ¯¯¯¯
/
/  Version:    
/  ¯¯¯¯¯¯¯
/
/  Notes:
/  ¯¯¯¯¯
/     This design makes use of some features from VHDL-2008, all of which have been implemented by
/  Altera and Xilinx in their software.
/     A 3 space tab is used throughout the document
/
/
/  Description:
/  ¯¯¯¯¯¯¯¯¯¯¯
/     Package to implement the multiplierless multiple constant multiplier proposed by Voronenko and
/  Püschel. The solutions are written to a file during simulation and read from that file during
/  synthesis.
/
 **************************************************************************************************/

library std;
   use std.textio.all;

library ieee;
   use ieee.std_logic_1164.all;
   use ieee.numeric_std.all;
   use ieee.math_real.all;

library work;
   use work.common_data_types_pkg.all;
   use work.common_pkg.all;
   use work.fixed_float_types.all;
   use work.fixed_generic_pkg.all;
   use work.real_const_mult_pkg.all;

/*================================================================================================*/
/*================================================================================================*/
/*================================================================================================*/

package mmcm_pkg is
   generic(
      MAX_TARGET : positive;     --the highest constant
      FILE_PATH  : string);      --the name of the file where the solution will be saved

   constant UPPER_BITS  : positive := 1+integer(ceil(log2(real(MAX_TARGET))));
   constant UPPER_LIMIT : positive := positive(2.0**(UPPER_BITS)-1);


/* data structures                                                                              0 */
/**************************************************************************************************/
   --vertex node type: used to describe the solution
   --one node: u<<l1 + (-1)^s*v<<l2 = w
   type vertex_node;

   type vertex_node_access is access vertex_node;

   type vertex_node is record
      w         : positive;
      u         : positive;
      l1        : natural;
      v         : positive;
      l2        : natural;
      s         : boolean;    --true for +, false for -
      next_node : vertex_node_access;
   end record;

   --vertex type
   type vertex;

   type vertex_access is access vertex;

   type vertex is record
      size : natural;
      head : vertex_node_access;
      tail : vertex_node_access;
   end record;


----------------------------------------------------------------------------------------------------
   --binary search tree node type
   type bst_node;

   type bst_node_access is access bst_node;

   type bst_node is record
      value : positive;
      left  : bst_node_access;
      right : bst_node_access;
   end record;

   --binary search tree type
   type bst;

   type bst_access is access bst;

   type bst is record
      size : natural;   --number of elements
      root : bst_node_access;
   end record;


----------------------------------------------------------------------------------------------------
   --linked list node type
   type llist_node;

   type llist_node_access is access llist_node;

   type llist_node is record
      value     : positive;
      next_node : llist_node_access;
   end record;

   --linked list type
   type llist;

   type llist_access is access llist;

   type llist is record
      head : llist_node_access;
      tail : llist_node_access;
   end record;


----------------------------------------------------------------------------------------------------
   --line access types
   type line_access is access line;

   type line_access_v is array (integer range <>) of line_access;


/* binary search trees procedures                                                               1 */
/**************************************************************************************************/
   --insert a value in a subtree
   procedure insert(
      node      : inout bst_node_access;
      new_value : in positive);

   --inserts a value in a tree
   procedure insert(
      tree      : inout bst_access;
      new_value : in positive);

   --rotates pointed node to the left of its right child
   procedure rotate_left(
      subtree : inout bst_node_access);

   --rotates pointed node to the right of its left child
   procedure rotate_right(
      subtree : inout bst_node_access);


   --deletes only one node, reconnecting its children to the rest of the tree
   procedure delete_node(
      node : inout bst_node_access);

   procedure delete_left(
      node : inout bst_node_access);

   procedure delete_right(
      node : inout bst_node_access);

   --deletes the first node it finds whose value is the same as the one given
   procedure delete_value(
      tree  : inout bst_access;
      value : in positive);

   --deletes the selected node and all its children
   procedure delete_subtree(
      node : inout bst_node_access);

   --deletes a whole tree
   procedure delete_tree(
      tree : inout bst_access);


   --looks for a value in a subtree, returns 0 in variable value if not found
   procedure search(
      variable node  : in bst_node_access;
      value          : inout natural);

   --looks for a value in a tree, returns 0 in variable value if not found
   procedure search(
      variable tree  : in  bst_access;
      value          : inout natural);


   --returns the maximum value in a tree; 0 if it is empty
   procedure max(
      variable node : in bst_node_access;
      max           : out natural);


   --calculates the height of a subtree
   procedure height(
      variable subtree : in bst_node_access;
      variable actual  : in natural;         --must be 1 when called
      variable max     : inout natural);

   --calculates the height of a tree
   procedure height(
      variable tree       : in bst_access;
      variable max_height : inout natural);


/* linked lists procedures                                                                      3 */
/**************************************************************************************************/
   procedure insert_in_position(     --inserts new value before the specified node
      node      : inout llist_node_access;
      new_value : in positive);

   procedure insert(    --inserts new value in the tail position
      llist     : inout llist_access;
      new_value : in positive);

   procedure insert_ordered(  --without repetitions
      llist     : inout llist_access;
      new_value : in positive);


   procedure delete_node( --deletes the assigned node of a linked list
      node : inout llist_node_access);

   procedure delete_value(
      llist : inout llist_access;
      value : in positive);

   --returns 0 in in_value if not found, it leaves it unchanged if found
   procedure search(
      variable llist : in llist_access;
      in_value       : inout natural);


   procedure empty( --empties a llist
      llist : inout llist_access);


   procedure union(
      dest          : inout llist_access;
      variable orig : in llist_access);

   procedure difference( --deletes the values in a which are also in b
      a          : inout llist_access;
      variable b : in llist_access);

/* message procedures                                                                           4 */
/**************************************************************************************************/

   procedure write_bst_recursive(
      variable tree : in bst_node_access;
      max_height    : in positive;
      h_actual      : inout natural;   --height_iterator
      msg_v         : inout line_access_v);

   procedure write(
      message       : inout line;
      variable node : in bst_node_access;
      max_height    : in positive);

   procedure write(
      message       : inout line;
      variable tree : in bst_access);

   procedure msg_debug(
      variable tree : in bst_access;
      name          : in string);

----------------------------------------------------------------------------------------------------

   procedure write(
      message       : inout line;
      variable node : in llist_node_access);

   procedure write(
      message       : inout line;
      variable list : in llist_access);

   procedure msg_debug(
      variable list : in llist_access;
      name          : in string);

----------------------------------------------------------------------------------------------------

   procedure msg_separator;


/* MMCM procedures                                                                              5 */
/**************************************************************************************************/
   procedure VorPus(
      target : positive_v);


end package;

/*================================================================================================*/
/*================================================================================================*/
/*================================================================================================*/

Package body mmcm_pkg is


/********************************************************************************************** 1 */

   procedure insert(
      node      : inout bst_node_access;
      new_value : in positive)
   is
   begin
      if node = null then
         node := new bst_node'(new_value, null, null);
      else
         if new_value > node.value then
            if node.right = null then
               node.right := new bst_node'(new_value, null, null);
            else
               node := node.right;
               insert(node, new_value);
            end if;
         elsif new_value < node.value then
            if node.left = null then
               node.left := new bst_node'(new_value, null, null);
            else
               node := node.left;
               insert(node, new_value);
            end if;
         else
            node := null;    --if nothing is inserted return null pointer
            return;
         end if;
      end if;
   end procedure;

   procedure insert(
      tree      : inout bst_access;
      new_value : in positive)
   is
      variable aux : bst_node_access := tree.root;
   begin
      insert(aux, new_value);
      if aux /= null then              --if the value was inserted (it wasn't already in the tree)
         tree.size := tree.size + 1;
         if tree.root = null then      --inserted into an empty tree
            tree.root := aux;
         end if;
      end if;
   end procedure;

   procedure insert(
      tree          : inout bst_access;
      variable list : in llist_access)
   is
      variable iter : llist_node_access;
   begin
      if tree /= null then
         if list /= null then
            iter := list.head;
            while iter /= null loop
               insert(tree, iter.value);
               iter := iter.next_node;
            end loop;
         end if;
      end if;
   end procedure;


   procedure rotate_left(
      subtree : inout bst_node_access)
   is
      variable aux : bst_node_access;
   begin
      if subtree /= null then
         if subtree.right /= null then
            aux := subtree.right;
            subtree.right := aux.left;
            aux.left := subtree;
            subtree := aux;
         end if;
      end if;
   end procedure;

   procedure rotate_right(
      subtree : inout bst_node_access)
   is
      variable aux : bst_node_access;
   begin
      if subtree /= null then
         if subtree.left /= null then
            aux := subtree.left;
            subtree.left := aux.right;
            aux.right := subtree;
            subtree := aux;
         end if;
      end if;
   end procedure;


   procedure delete_node(
      node : inout bst_node_access)
   is
      variable aux : bst_node_access;
   begin

      if node.left = null and node.right = null then --if no children, delete node
         deallocate(node);
         node := null;
      elsif node.left = null then      --right child replaces parent if left child doesn't exist
         aux  := node;
         node := node.right;
         deallocate(aux);
      elsif node.right = null then     --left child replaces parent if left child doesn't exist
         aux  := node;
         node := node.left;
         deallocate(aux);
      else                             --both children are present: introduce rightmost from the left subtree
         aux := node.left;
         if aux.right = null then               --left child doesn't have right child
            aux.right := node.right;
            deallocate(node);
            node := aux;
         else                                   --move to the right child until the node before the last 
            while aux.right.right /= null loop
               aux := aux.right;
            end loop;
            node.value := aux.right.value;
            aux.right := aux.right.left;
            deallocate(aux.right);
         end if;
      end if;

   end procedure;


   procedure delete_left(
      node : inout bst_node_access)       --the real pointer from the linked list(not a copy)
   is
   begin
      delete_node(node.left);
   end procedure;


   procedure delete_right(
      node : inout bst_node_access)       --the real pointer from the linked list(not a copy)
   is
      variable aux : bst_node_access;
   begin
      delete_node(node.right);
   end procedure;


   procedure delete_value(
      tree  : inout bst_access;
      value : in positive)
   is
      variable parent : bst_node_access;
      variable node : bst_node_access;
      variable dir : integer := 0;
   begin
      if tree /= null then
         node := tree.root;
         while node /= null loop          --while tree is not empty
            if node.value = value then
               if parent = null then      --if deleting root
                  if node.right /= null then       --if right child exists
                     node.value:= node.right.value;      --put its value in root
                     delete_node(node.right);            --and delete right child
                     tree.size := tree.size - 1;
                  elsif node.left /= null then     --if left child exists
                     node.value:= node.left.value;      --put its value in root
                     delete_node(node.left);            --and delete left child
                     tree.size := tree.size - 1;
                  else                             --if there are no more nodes in the tree
                     deallocate(tree.root);
                     tree.size := 0;
                     tree.root := null;            --delete everything
                     end if;
               else
                  if dir = -1 then
                     delete_left(parent);
                     tree.size := tree.size - 1;
                  else --dir=1
                     delete_right(parent);
                     tree.size := tree.size - 1;
                  end if;
                  return;
               end if;
            elsif node.value < value then --not deleting the root
               parent := parent.left when dir=-1 else 
                         parent.right when dir=1 else
                         tree.root;
               node := node.right;
               dir := 1;
            else
               parent := parent.left when dir=-1 else 
                         parent.right when dir=1 else
                         tree.root;
               node := node.left;
               dir := -1;
            end if;
         end loop;
      elsif DEBUGGING then
            report "delete_value(tree, value) couldn't find the value to delete (" & image(value) & ")."
               severity warning;
      end if;
   end procedure;


   --doesn't update the value of tree.size (not possible from within)
   procedure delete_subtree(
      node : inout bst_node_access)
   is
   begin
      if node.left /= null then        --post-order traversal: delete only when all descendents are deleted
         delete_subtree(node.left);
      end if;
      if node.right /= null then
         delete_subtree(node.right);
      end if;
      delete_node(node);
   end procedure;


   procedure delete_tree(
      tree : inout bst_access)
   is
   begin
      delete_subtree(tree.root);
      tree.size := 0;
   end procedure;


   --looks for a value in a subtree, returns 0 in variable value if not found
   procedure search(
      variable node  : in bst_node_access;
      value          : inout natural)
   is
   begin
      if node = null then
         value := 0;
         return;
      elsif value > node.value then
         search(node.right, value);
      elsif value < node.value then
         search(node.left, value);
      else
         return;
      end if;
   end procedure;

   --looks for a value in a tree, returns 0 in variable value if not found
   procedure search(
      variable tree  : in bst_access;
      value          : inout natural)
   is
      variable aux : bst_node_access;
   begin
      if tree /= null then
         aux := tree.root;
         search(aux, value);           --after this, value is 0 if not found
      end if;
   end procedure;


   --returns the biggest number in the subtree, 0 if the subtree is empty
   procedure max(
      variable node : in bst_node_access;
      max           : out natural)
   is
      variable node_ite : bst_node_access := node;
   begin
      max := 0;
      while node_ite /= null loop
         max := node_ite.value;
         node_ite := node_ite.right;
      end loop;
   end procedure;


   procedure height(
      variable subtree : in bst_node_access;
      variable actual  : in natural;
      variable max     : inout natural)
   is
      variable aux : natural;
   begin
      if subtree /= null then
         if subtree.left /= null then
            aux := actual + 1;
            if aux > max then
               max := aux;
            end if;
            height(subtree.left, aux, max);
         end if;
         if subtree.right /= null then
            aux := actual + 1;
            if aux > max then
               max := aux;
            end if;
            height(subtree.right, aux, max);
         end if;
      end if;
   end procedure;


   procedure height(
      variable tree       : in bst_access;
      variable max_height : inout natural)
   is
      variable max    : natural := 0;
      variable actual : natural;
   begin
      if tree /= null then
         if tree.root /= null then
            actual := 1;
            max := 1;
            height(tree.root, actual, max);
         end if;
      end if;
      max_height := max;
   end procedure;


/********************************************************************************************** 3 */

   --inserts before the assigned node
   procedure insert_in_position(
      node      : inout llist_node_access;
      new_value : in positive)
   is
      variable aux : llist_node_access;
   begin
      if node = null then
         report "insert_in_position(llist_node_access, positive) : llist_node_access is null"
            severity warning;
      else
         aux := new llist_node'(node.value, node.next_node);
         node.value     := new_value;
         node.next_node := aux;
      end if;
   end procedure;

   --inserts new value in the tail
   procedure insert(
      llist     : inout llist_access;
      new_value : in positive)
   is
   begin
      if llist.head = null then
         llist.head := new llist_node'(new_value, null);
         llist.tail := llist.head;
      else
         llist.tail.next_node := new llist_node'(new_value, null);
         llist.tail := llist.tail.next_node;
      end if;
   end procedure;

   --inserts all values in a positive vector into a linked list without repetitions
   procedure insert(
      llist  : inout llist_access;
      vector : in positive_v)
   is
   begin
      for i in vector'range loop
         insert_ordered(llist, vector(i));
      end loop;
   end procedure;

   procedure insert_ordered(  --without repetitions, ordered from lowest(head) to highest(tail)
      llist     : inout llist_access;
      new_value : in positive)
   is
      variable node_ite : llist_node_access := llist.head;
   begin

      while1:
      while node_ite /= null loop
         if node_ite.value > new_value then
            exit while1;
         elsif node_ite.value = new_value then
            return;
         end if;
         node_ite := node_ite.next_node;
      end loop;

      if node_ite /= null then      --if not last position (=> at least one element)
         insert_in_position(node_ite, new_value);
         if llist.tail.next_node /= null then   --if the tail is not in the tail anymore
            llist.tail := llist.tail.next_node;
         end if;
         if llist.head = llist.tail then  --if the list only had one element
            llist.tail := llist.head.next_node;
         end if;
      else                             --insert in the tail
         insert(llist, new_value);     --this automatically updates .tail
      end if;

   end procedure;

   --deleted a node and returns the pointer to the next one (or null if it was the tail)
   procedure delete_node( --deletes the given node (must be the access variable of the previous node)
      node : inout llist_node_access)
   is
      variable aux : llist_node_access;
   begin
      aux := node;
      node := node.next_node;
      deallocate(aux);
   end procedure;


   procedure delete_value( --deletes a value in a linked list, warns if it doesn't exist
      llist : inout llist_access;
      value : in positive)
   is
      variable aux : llist_node_access;
      variable node_ite : llist_node_access := llist.head;
   begin
      if node_ite = null then     --if empty list
         msg_debug("delete_value(llist, value) couldn't find the value to delete (" & image(value) & ").");
         return;
      end if;
      --value found in the first node
      if llist.head.value = value then            --the value is in the first node
         if llist.head.next_node = null then      --the list has only one node
            deallocate(llist.head);
            llist.head := null;
            llist.tail := null;
            return;
         else                                     --the list has more than a node
            aux := llist.head;
            llist.head := llist.head.next_node;
            deallocate(aux);
            return;
         end if;
      end if;
      --traverse the list until finding the desired value
      while node_ite.next_node /= null loop     --the real access variable(needed to re-establish the connection)
         if node_ite.next_node.value = value then
            delete_node(node_ite.next_node);
            if node_ite.next_node = null then  --if we deleted the last node, update tail
               llist.tail := node_ite;
            end if;
            return;
         end if;
         node_ite:= node_ite.next_node;
      end loop;
      msg_debug("delete_value(llist, value) couldn't find the value to delete (" & image(value) & ").");
   end procedure;


   procedure search( --changes in_value parameter to 0 if the element is not in the linked list
      variable llist : in llist_access;
      in_value       : inout natural)
   is
      variable node_ite : llist_node_access := llist.head;
   begin
      while node_ite /= null loop
         if node_ite.value = in_value then
            return;    --value in the linked list
         end if;
         node_ite := node_ite.next_node;
      end loop;
      in_value := 0;      --value not in the linked list
   end procedure;


   procedure empty( --empty a llist
      llist : inout llist_access)
   is
      variable node_ite : llist_node_access := llist.head;
      variable aux      : llist_node_access;
   begin
      if llist.head.next_node = null then
         deallocate(llist.head);
         llist.head := null;
         llist.tail := null;
         return;
      end if;
      while node_ite.next_node /= null loop
         aux := node_ite;
         node_ite := node_ite.next_node;
         deallocate(aux);
      end loop;
      deallocate(node_ite);
      llist.head := null;
      llist.tail := null;
   end procedure;


   procedure union( --adds the values in orig to dest
      dest          : inout llist_access;
      variable orig : in llist_access)
   is
      variable orig_ite : llist_node_access := orig.head;
   begin
      while orig_ite /= null loop
         insert_ordered(dest, orig_ite.value);
         orig_ite := orig_ite.next_node;
      end loop;
   end procedure;


   procedure difference( --deletes the values in a which are also in b
      a          : inout llist_access;
      variable b : in llist_access)
   is
      variable a_ite : llist_node_access := a.head;
      variable b_ite : llist_node_access := b.head;
   begin
      if a_ite /= null then
         --check from the second to the tail
         aloop: while a_ite.next_node /= null loop
            while b_ite /= null loop
               if a_ite.next_node.value = b_ite.value then
                  delete_value(a, b_ite.value);
                  next aloop;                      --next loop of a without getting next node
               end if;
               b_ite := b_ite.next_node;
            end loop;
            a_ite := a_ite.next_node;
         end loop;
      end if;
      --check head node
      b_ite := b.head;
      if b_ite /= null then
         if a.head.value = b_ite.value then
            delete_value(a, b_ite.value);
         end if;
      end if;
   end procedure;


/********************************************************************************************** 4 */

   procedure write(
      message       : inout line;
      variable node : in vertex_node_access)
   is
   begin
      if node /= null then
         if node.w=1 then
            write(message, string'("1") & LF);
         else
            write(message, string'( image(node.w) & " = " &
                                    image(node.u) & ite(node.l1=0, " ","<<" & image(node.l1)) &
                                    ite(node.s, " - ", " + ") &
                                    image(node.v) & ite(node.l2=0, " ", "<<" & image(node.l2))
                                   )
                  );
            if node.next_node /= null then
               write(message, LF);
            end if;
         end if;
      else
         write(message, string'("-> empty vertex"));
      end if;
   end procedure;

   procedure write(
      message         : inout line;
      variable vertex : in vertex_access)
   is
      variable ite : vertex_node_access;
   begin
      if vertex /= null then
         ite := vertex.head;
         while ite /= null loop
            write(message, ite);
            ite := ite.next_node;
         end loop;
      end if;
   end procedure;

   procedure msg_debug(
      variable vertex : in vertex_access;
      name            : in string)
   is
      variable message : line;
   begin
      if DEBUGGING then
         write(message, "**************************" & LF);
         write(message, name & LF);
         write(message, vertex);
         writeline(OUTPUT, message);
      end if;
   end procedure;

   procedure msg(
      variable vertex : in vertex_access;
      name            : in string)
   is
      variable message : line;
   begin
      write(message, "**************************" & LF);
      write(message, name & LF);
      write(message, vertex);
      writeline(OUTPUT, message);
   end procedure;

----------------------------------------------------------------------------------------------------

   function length(
      number : positive)
   return positive is
   begin
      return positive(ceil(log10(real(number+1))));
   end function;

   procedure write_bst_recursive(
      variable tree : in bst_node_access;
      max_height    : in positive;
      h_actual      : inout natural;   --height_iterator
      msg_v         : inout line_access_v)
   is
      variable x : natural;
   begin
      if tree /= null then
         if tree.left /= null then
            x := h_actual + 1;
            write_bst_recursive(tree.left, max_height, x, msg_v);
         end if;

         for i in 1 to max_height loop
            if i = h_actual then
               write(msg_v(i).all, to_string(tree.value));
            else
               for j in 1 to length(tree.value) loop
                  write(msg_v(i).all, string'(" "));
               end loop;
            end if;
         end loop;

         if tree.right /= null then
            x := h_actual + 1;
            write_bst_recursive(tree.right, max_height, x, msg_v);
         end if;

      end if;
   end procedure;


   procedure write(
      message       : inout line;
      variable node : in bst_node_access;
      max_height    : in positive)
   is
      variable h_actual  : natural := 1;
      variable message_v : line_access_v(1 to max_height);
   begin
      if node = null then
         write(message, string'("empty tree"));
      else
         for i in 1 to max_height loop
            message_v(i) := new line;
         end loop;
         write_bst_recursive(node, max_height, h_actual, message_v);
         for i in 1 to max_height loop
            write(message, message_v(i).all.all);
            if i /= max_height then
               write(message, LF);
            end if;
         end loop;
      end if;
   end procedure;


   procedure write(
      message       : inout line;
      variable tree : in bst_access)
   is
      variable max_height : positive;
   begin
      if tree /= null then
         height(tree, max_height);
         write(message, tree.root, max_height);
      end if;
   end procedure;


   procedure msg_debug(
      variable tree : in bst_access;
      name          : in string)
   is
      variable message : line;
   begin
      if DEBUGGING then
         write(message, "**************************" & LF);
         write(message, name & " (size " & image(tree.size) & ")" & LF);
         if tree.root /= null then
            write(message, tree);
         else
            write(message, string'("(empty)"));
         end if;
         writeline(OUTPUT, message);
      end if;
   end procedure;

   procedure msg(
      variable tree : in bst_access;
      name          : in string)
   is
      variable message : line;
   begin
      write(message, "**************************" & LF);
      write(message, name & " (size " & image(tree.size) & ")" & LF);
      if tree.root /= null then
         write(message, tree);
      else
         write(message, string'("(empty)"));
      end if;
      writeline(OUTPUT, message);
   end procedure;

----------------------------------------------------------------------------------------------------

   procedure write(
      message       : inout line;
      variable node : in llist_node_access)
   is
      variable ite : llist_node_access := node;
   begin
      if node /= null then
         while ite /= null loop
            write(message, string'(" -> ") & image(ite.value));
            ite := ite.next_node;
         end loop;
      else
         write(message, string'("-> empty list"));
      end if;
   end procedure;

   procedure write(
      message       : inout line;
      variable list : in llist_access)
   is
   begin
      write(message, list.head);
   end procedure;

   procedure msg_debug(
      variable list : in llist_access;
      name          : in string)
   is
      variable message : line;
   begin
      if DEBUGGING then
         write(message, "**************************" & LF);
         write(message, name & LF);
         write(message, list);
         writeline(OUTPUT, message);
      end if;
   end procedure;

   procedure msg(
      variable list : in llist_access;
      name          : in string)
   is
      variable message : line;
   begin
      write(message, "**************************" & LF);
      write(message, name & LF);
      write(message, list);
      writeline(OUTPUT, message);
   end procedure;

----------------------------------------------------------------------------------------------------

   procedure msg_separator
   is
      variable message : line;
   begin
      write(message, string'("**************************"));
      writeline(OUTPUT, message);
   end procedure;


/********************************************************************************************** 5 */

   function number_of_iterations(
      a : positive;
      b : positive)
   return positive is
   begin
      return maximum(integer(floor(log2((0.000000001+real(UPPER_LIMIT+a))/real(b)))), 1);
      --0.000000001 added because function log2 sometimes returns something like log2(128)=6.999999999
   end function;

   --generates the A_* (R,W) : vertex fundamental set
   -- it directly generates the ordered linked list that contains the values of C^1
   procedure generateC1(
      result      : inout llist_access)
   is
      variable aux : integer;
   begin
      for i in 1 to number_of_iterations(1, 1) loop--start at 1 instead of 0 because values when i=0 are included in i=1 
      -- (just number 1) and we avoid having to discard even values as they all will be odd
         aux := integer(2.0**i) - 1;
         insert_ordered(result, aux);

         aux := aux + 2;     -- = integer(2.0**i) + 1
         if aux< UPPER_LIMIT then
            insert_ordered(result, aux);
         end if;
      end loop;
   end procedure;


   --generates the S U A_*(R,W)-W : vertex fundamental set
   procedure compute_d1_successors(
      s_set          : inout bst_access;
      variable r_set : in llist_access;
      variable w_set : in llist_access)
   is
      variable r_ite      : llist_node_access := r_set.head;
      variable w_ite      : llist_node_access := w_set.head;
      variable aux        : natural;
      variable r          : positive;
      variable w          : positive;
      variable iterations : positive;
   begin

      while r_ite /= null loop
         while w_ite /= null loop
            r := r_ite.value;
            w := w_ite.value;

            iterations := number_of_iterations(w, r);
            for i in 0 to iterations loop
               aux := w + r*integer(2.0**i);
               if aux < UPPER_LIMIT then
                  aux := reduce_to_odd(aux);
                  insert(s_set, aux);
               end if;

               aux := abs(integer(w) - integer(r*integer(2.0**i)));
               if aux /= 0 then
                  insert(s_set, reduce_to_odd(aux));   --reduce_to_odd is here to prevent reduce_to_odd(0)
               end if;
            end loop;

            if r /= w then
               iterations := number_of_iterations(r, w);
               for i in 0 to iterations loop
                  aux := r + w*integer(2.0**i);
                  if aux < UPPER_LIMIT then
                     aux := reduce_to_odd(aux);
                     insert(s_set, aux);
                  end if;

                  aux := abs(integer(r) - integer(w*integer(2.0**i)));
                  if aux /= 0 then
                     insert(s_set, reduce_to_odd(aux));   --reduce_to_odd is here to prevent reduce_to_odd(0)
                  end if;
               end loop;
            end if;

            w_ite := w_ite.next_node;
         end loop;
         w_ite := w_set.head;
         r_ite := r_ite.next_node;
      end loop;

      --delete W from S
      w_ite := r_set.head;
      while w_ite /= null loop
         delete_value(s_set, w_ite.value);
         w_ite := w_ite.next_node;
      end loop;
   end procedure;


   --modified Day-Stout-Warren algorithm to balance a binary search tree
   --it only performs the second part of the algorithm (we assume the received tree is already a listlike tree)
   --it will be used only after inserting C1 and at the end it performs an additional rotate left compared with
   --   the original algorithm so as to compensate the fact that the inserted values are biased towards low values
   --With this change, after inserting successive successors, the tree will be more balanced
   procedure dsw(
      s_set : inout bst_access;
      n     : in natural)
   is
      variable s_ite : bst_node_access;
      variable m     : natural;
      variable aux   : natural := 0;
   begin
      if s_set /= null then
         m := natural((2.0**log2(real(n)+1))-1);
         rotate_left(s_set.root);
         aux := aux + 1;
         if n > m + 1 then
            for i in 1 to n - m - 1 loop
               s_ite := s_set.root;
               for j in 1 to i loop
                  s_ite := s_ite.right;
               end loop;
               rotate_left(s_ite.right);
               aux := aux + 1;
            end loop;
         end if;
         m := m - aux;
         m := natural(floor(real(m)/2));
         while m > 1 loop
            for i in 1 to m loop
               if i = 1 then
                  rotate_left(s_set.root);
               elsif i = 2 then
                  rotate_left(s_set.root.right);
               else
                  s_ite := s_set.root;
                  for j in 1 to i-2 loop
                     s_ite := s_ite.right;
                  end loop;
                  rotate_left(s_ite.right);
               end if;
            end loop;
            m := natural(floor(real(m)/2));
         end loop;
         if s_ite /= null then
            rotate_left(s_ite.right);
         end if;
      end if;
   end procedure;


----------------------------------------------------------------------------------------------------


   --test1, distance-1, (t/C1 = s)
   procedure test_1(
      variable C1 : in llist_access;
      s           : in positive;
      t           : in positive;
      result      : out boolean)
   is
      variable value  : natural;
   begin
      if t mod s = 0 then   --only if the division is exact
         value := t / s;
         search(C1, value);
         if value /= 0 then            --it was found
            result := true;
            return;
         end if;
      end if;
      result := false;
   end procedure;


   --test2, distance-2, (A_*(t,R) = s)
   procedure test_2(
      variable r_set : in llist_access;
      s              : in positive;
      t              : in positive;
      result         : out boolean)
   is
      variable r_ite      : llist_node_access := r_set.head;
      variable aux        : natural;
      variable r          : positive;
      variable iterations : positive;
   begin
      while r_ite /= null loop
         r := r_ite.value;

         iterations := number_of_iterations(t, r);
         for i in 0 to iterations loop
            aux := t + r*integer(2.0**i);
            if aux < UPPER_LIMIT then
               aux := reduce_to_odd(aux);
               if aux = s then
                  result := true;
                  return;
               end if;
            end if;

            aux := abs(integer(t) - integer(r*integer(2.0**i)));
            if aux /= 0 then
               aux := reduce_to_odd(aux);   --reduce_to_odd is here to prevent reduce_to_odd(0)
               if aux = s then
                  result := true;
                  return;
               end if;
            end if;
         end loop;

         if r /= t then
            iterations := number_of_iterations(r, t);
            for i in 0 to iterations loop
               aux := r + t*integer(2.0**i);
               if aux < UPPER_LIMIT then
                  aux := reduce_to_odd(aux);
                  if aux = s then
                     result := true;
                     return;
                  end if;
               end if;

               aux := abs(integer(r) - integer(t*integer(2.0**i)));
               if aux /= 0 then
                  aux := reduce_to_odd(aux);   --reduce_to_odd is here to prevent reduce_to_odd(0)
                  if aux = s then
                     result := true;
                     return;
                  end if;
               end if;
            end loop;
         end if;

         r_ite := r_ite.next_node;
      end loop;
      result := false;
   end procedure;


   --test3, distance-3, (t/C2 = s)
   procedure test_3(
      variable C1 : in llist_access;
      s           : in positive;
      t           : in positive;
      result      : out boolean)
   is
      variable value : natural;
      variable aux   : natural;
      variable ite   : llist_node_access := C1.head;
   begin
      if t mod s = 0 then   --only if the division is exact
         value := t / s;
         while ite /= null loop
            if value mod ite.value = 0 then
               aux := value/ite.value;
               search(C1, aux);
               if aux /= 0 then            --it was found
                  result := true;
                  return;
               end if;
            end if;
            ite := ite.next_node;
         end loop;
      end if;
      result := false;
   end procedure;


   --test4, distance-3, (A_*(t/C1,R) = s)
   procedure test_4(
      variable C1    : in llist_access;
      variable r_set : in llist_access;
      s              : in positive;
      t              : in positive;
      result         : out boolean)
   is
      variable r_ite      : llist_node_access := r_set.head;
      variable c1_ite     : llist_node_access := C1.head;
      variable aux1, aux2 : natural;
      variable r, c       : positive;
      variable iterations : positive;
   begin
      while r_ite /= null loop
         r := r_ite.value;
         while c1_ite /= null loop
            c := c1_ite.value;
            if t mod c = 0 then
               aux1 := t/c;

               iterations := number_of_iterations(aux1, r);
               for i in 0 to iterations loop
                  aux2 := aux1 + r*integer(2.0**i);
                  if aux2 < UPPER_LIMIT then
                     aux2 := reduce_to_odd(aux2);
                     if aux2 = s then
                        result := true;
                        return;
                     end if;
                  end if;

                  aux2 := abs(integer(aux1) - integer(r*integer(2.0**i)));
                  if aux2 /= 0 then
                     aux2 := reduce_to_odd(aux2);   --reduce_to_odd is here to prevent reduce_to_odd(0)
                     if aux2 = s then
                        result := true;
                        return;
                     end if;
                  end if;
               end loop;

               if r /= aux1 then
                  iterations := number_of_iterations(r, aux1);
                  for i in 0 to iterations loop
                     aux2 := r + aux1*integer(2.0**i);
                     if aux2 < UPPER_LIMIT then
                        aux2 := reduce_to_odd(aux2);
                        if aux2 = s then
                           result := true;
                           return;
                        end if;
                     end if;

                     aux2 := abs(integer(r) - integer(aux1*integer(2.0**i)));
                     if aux2 /= 0 then
                        aux2 := reduce_to_odd(aux2);   --reduce_to_odd is here to prevent reduce_to_odd(0)
                        if aux2 = s then
                           result := true;
                           return;
                        end if;
                     end if;
                  end loop;
               end if;

            end if;
            c1_ite := c1_ite.next_node;
         end loop;
         r_ite := r_ite.next_node;
      end loop;
      result := false;
   end procedure;


   --test5, distance-3, (A_*(t,R)/C1 = s)
   procedure test_5(
      variable C1    : in llist_access;
      variable r_set : in llist_access;
      s              : in positive;
      t              : in positive;
      result         : out boolean)
   is
      variable r_ite      : llist_node_access := r_set.head;
      variable c1_ite     : llist_node_access := C1.head;
      variable aux        : natural;
      variable r, c       : positive;
      variable iterations : positive;
   begin
      while r_ite /= null loop
         r := r_ite.value;

         iterations := number_of_iterations(t, r);
         for i in 0 to iterations loop
            aux := t + r*integer(2.0**i);
            while c1_ite /= null loop
               c := c1_ite.value;
               if aux mod c = 0 then
                  c := aux / c;
                  if c < UPPER_LIMIT then
                     c := reduce_to_odd(c);
                     if c = s then
                        result := true;
                        return;
                     end if;
                  end if;
               end if;
               c1_ite := c1_ite.next_node;
            end loop;
            c1_ite := C1.head;

            aux := abs(integer(t) - integer(r*integer(2.0**i)));
            if aux /= 0 then
               while c1_ite /= null loop
                  c := c1_ite.value;
                  if aux mod c = 0 then
                     c := aux / c;
                     if c < UPPER_LIMIT then
                        c := reduce_to_odd(c);
                        if c = s then
                           result := true;
                           return;
                        end if;
                     end if;
                  end if;
                  c1_ite := c1_ite.next_node;
               end loop;
            end if;
            c1_ite := C1.head;
         end loop;

         if r /= t then
            iterations := number_of_iterations(r, t);
            for i in 0 to iterations loop
               aux := r + t*integer(2.0**i);
               while c1_ite /= null loop
                  c := c1_ite.value;
                  if aux mod c = 0 then
                     c := aux / c;
                     if c < UPPER_LIMIT then
                        c := reduce_to_odd(c);
                        if c = s then
                           result := true;
                           return;
                        end if;
                     end if;
                  end if;
                  c1_ite := c1_ite.next_node;
               end loop;
               c1_ite := C1.head;

               aux := abs(integer(r) - integer(t*integer(2.0**i)));
               if aux /= 0 then
                  while c1_ite /= null loop
                     c := c1_ite.value;
                     if aux mod c = 0 then
                        c := aux / c;
                        if c < UPPER_LIMIT then
                           c := reduce_to_odd(c);
                           if c = s then
                              result := true;
                              return;
                           end if;
                        end if;
                     end if;
                     c1_ite := c1_ite.next_node;
                  end loop;
               end if;
            end loop;
         end if;

         r_ite := r_ite.next_node;
      end loop;
      result := false;
   end procedure;


   --test6, distance-3, (A_*(s, t) intersetion S)
   procedure test_6(
      variable s_set : in bst_access;
      s              : in positive;
      t              : in positive;
      result         : out boolean)
   is
      variable aux        : natural;
      variable iterations : positive;
   begin

         iterations := number_of_iterations(t, s);
         for i in 0 to iterations loop
            aux := t + s*integer(2.0**i);
            if aux < UPPER_LIMIT then
               aux := reduce_to_odd(aux);
               search(s_set, aux);
               if aux /= 0 then
                  result := true;
                  return;
               end if;
            end if;

            aux := abs(integer(t) - integer(s*integer(2.0**i)));
            if aux /= 0 then
               aux := reduce_to_odd(aux);
               search(s_set, aux);
               if aux /= 0 then
                  result := true;
                  return;
               end if;
            end if;
         end loop;

         if s /= t then
            iterations := number_of_iterations(s, t);
            for i in 0 to iterations loop
               aux := s + t*integer(2.0**i);
               if aux < UPPER_LIMIT then
                  aux := reduce_to_odd(aux);
                  search(s_set, aux);
                  if aux /= 0 then
                     result := true;
                     return;
                  end if;
               end if;

               aux := abs(integer(s) - integer(t*integer(2.0**i)));
               if aux /= 0 then
                  aux := reduce_to_odd(aux);
                  search(s_set, aux);
                  if aux /= 0 then
                     result := true;
                     return;
                  end if;
               end if;
            end loop;
         end if;

      result := false;
   end procedure;


----------------------------------------------------------------------------------------------------


   function csd_cost(
      number : positive)
   return positive is
      constant number_uf  : u_ufixed := to_ufixed(real(number), min_bits(number), 0);
      variable number_csd : T_csd(number_uf'range) := to_csd(number_uf);
      variable result : natural := 0;
   begin
      for i in number_csd'range loop
         if number_csd(i) /= "00" then
            result := result + 1;
         end if;
      end loop;
      return ite(result=1, result, result - 1);  --one shift and the unshifted signal can be added together
   end function;


   procedure distance_estimation(
      variable C1 : in llist_access;
      s           : in positive;
      t           : in positive;
      Est         : inout natural)     --must be the previous dist_Rt when called
   is
      variable c1_ite : llist_node_access := C1.head;
      variable term1, term2, c : positive;
      variable aux : natural;
      variable E1 : positive;
      variable iterations : positive;
   begin
      --estimator 1: E1=1+Est(A_*(s, t))
      term1 := s;
      term2 := t;
      iterations := number_of_iterations(term1, term2);
      for i in 0 to iterations loop
         aux := term1 + term2*integer(2.0**i);
         if aux < UPPER_LIMIT then
            aux := 1 + csd_cost(reduce_to_odd(aux));
            if aux < Est then
               Est := aux;
            end if;
         end if;
         aux := abs(integer(term1) - integer(term2*integer(2.0**i)));
         if aux /= 0 and aux < UPPER_LIMIT then
            aux := 1 + csd_cost(reduce_to_odd(aux));
            if aux < Est then
               Est := aux;
            end if;
         end if;
      end loop;
      iterations := number_of_iterations(term2, term1);
      for i in 0 to iterations loop
         aux := term2 + term1*integer(2.0**i);
         if aux < UPPER_LIMIT then
            aux := 1 + csd_cost(reduce_to_odd(aux));
            if aux < Est then
               Est := aux;
            end if;
         end if;
         aux := abs(integer(term2) - integer(term1*integer(2.0**i)));
         if aux /= 0 and aux < UPPER_LIMIT then
            aux := 1 + csd_cost(reduce_to_odd(aux));
            if aux < Est then
               Est := aux;
            end if;
         end if;
      end loop;
      
      --estimator 2: E2=2+Est(A_*(s, t/C1))
      term1 := s;
      while c1_ite /= null loop
         c := c1_ite.value;
         if t mod c = 0 then
            term2 := t/c;
            iterations := number_of_iterations(term1, term2);
            for i in 0 to iterations loop
               aux := term1 + term2*integer(2.0**i);
               if aux < UPPER_LIMIT then
                  aux := 2 + csd_cost(reduce_to_odd(aux));
                  if aux < Est then
                     Est := aux;
                  end if;
               end if;
               aux := abs(integer(term1) - integer(term2*integer(2.0**i)));
               if aux /= 0 then
                  aux := 2 + csd_cost(reduce_to_odd(aux));
                  if aux < Est then
                     Est := aux;
                  end if;
               end if;
            end loop;
            iterations := number_of_iterations(term2, term1);
            for i in 0 to iterations loop
               aux := term2 + term1*integer(2.0**i);
               if aux < UPPER_LIMIT then
                  aux := 2 + csd_cost(reduce_to_odd(aux));
                  if aux < Est then
                     Est := aux;
                  end if;
               end if;
               aux := abs(integer(term2) - integer(term1*integer(2.0**i)));
               if aux /= 0 and aux < UPPER_LIMIT then
                  aux := 2 + csd_cost(reduce_to_odd(aux));
                  if aux < Est then
                     Est := aux;
                  end if;
               end if;
            end loop;
         end if;
         c1_ite := c1_ite.next_node;
      end loop;
      --estimator 3: E3=2+Est(A_*(C1*s, t))
      c1_ite := c1.head;
      term1 := t;
      loopw: while c1_ite /= null loop
         c := c1_ite.value;
         term2 := s*c;
         if s*c > UPPER_LIMIT then
            exit loopw;
         else
            iterations := number_of_iterations(term1, term2);
            for i in 0 to iterations loop
               aux := term1 + term2*integer(2.0**i);
               if aux < UPPER_LIMIT then
                  aux := 2 + csd_cost(reduce_to_odd(aux));
                  if aux < Est then
                     Est := aux;
                  end if;
               end if;
               aux := abs(integer(term1) - integer(term2*integer(2.0**i)));
               if aux /= 0 then
                  aux := 2 + csd_cost(reduce_to_odd(aux));
                  if aux < Est then
                     Est := aux;
                  end if;
               end if;
            end loop;
            iterations := number_of_iterations(term2, term1);
            for i in 0 to iterations loop
               aux := term2 + term1*integer(2.0**i);
               if aux < UPPER_LIMIT then
                  aux := 2 + csd_cost(reduce_to_odd(aux));
                  if aux < Est then
                     Est := aux;
                  end if;
               end if;
               aux := abs(integer(term2) - integer(term1*integer(2.0**i)));
               if aux /= 0 and aux < UPPER_LIMIT then
                  aux := 2 + csd_cost(reduce_to_odd(aux));
                  if aux < Est then
                     Est := aux;
                  end if;
               end if;
            end loop;
         end if;
         c1_ite := c1_ite.next_node;
      end loop;

   end procedure;


   procedure calculate_first_dist_Rt(
      variable C1    : in llist_access;
      variable t_set : in llist_access;
      dist           : out natural)
   is
      variable aux  : natural := 0;
      variable top  : natural;
      variable iter : llist_node_access;
   begin
      if t_set /= null then
         iter := t_set.head;
         while iter /= null loop
            top := natural'high;
            distance_estimation(C1, 1, iter.value, top);
            aux := aux + top;
            iter := iter.next_node;
         end loop;
         dist := aux;
      end if;
   end procedure;


   procedure update_dist_Rt(
      dist_Rt        : inout positive;
      variable C1    : in llist_access;
      variable r_set : in llist_access;
      variable s_set : in bst_access;
      s              : in positive;
      variable t_set : in llist_access)
   is
      variable t_ite  : llist_node_access;
      variable t      : positive;
      variable bool   : boolean;
      variable result : natural := natural'high;
      variable Est    : positive;
   begin
      if t_set /= null then
         t_ite := t_set.head;
         --only update dist_Rt when taking an s whose distance has been estimated
         while t_ite /= null loop
            t :=  t_ite.value;
            if t = s then
               return;
            end if;
            test_1(C1, s, t, bool);
            if bool then 
               return;
            end if;
            test_2(r_set, s, t, bool);
            if bool then
               return;
            end if;
            test_3(C1, s, t, bool);
            if bool then
               return;
            end if;
            test_4(C1, r_set, s, t, bool);
            if bool then
               return;
            end if;
            test_5(C1, r_set, s, t, bool);
            if bool then
               return;
            end if;
            test_6(s_set, s, t, bool);
            if bool then
               return;
            end if;
            Est := dist_Rt;
            distance_estimation(C1, s, t, Est);
            if Est < result then
               result := Est;
            end if;
            t_ite := t_ite.next_node;
         end loop;
         dist_Rt := Est;
      end if;
   end procedure;


   procedure distance(
      variable C1    : in llist_access;
      variable r_set : in llist_access;
      variable s_set : in bst_access;
      s              : in positive;
      t              : in positive;
      dist_Rt        : inout positive;
      dist_Rst       : out positive)
   is
      variable bool : boolean;
      variable Est  : positive := dist_Rt;
   begin
      test_1(C1, s, t, bool);
      if bool then
         dist_Rt  := 2;
         dist_Rst := dist_Rt-1;
         return;
      end if;
      test_2(r_set, s, t, bool);
      if bool then
         dist_Rt  := 2;
         dist_Rst := dist_Rt - 1;
         return;
      end if;
      test_3(C1, s, t, bool);
      if bool then
         dist_Rt  := 3;
         dist_Rst := dist_Rt - 1;
         return;
      end if;
      test_4(C1, r_set, s, t, bool);
      if bool then
         dist_Rt  := 3;
         dist_Rst := dist_Rt - 1;
         return;
      end if;
      test_5(C1, r_set, s, t, bool);
      if bool then
         dist_Rt  := 3;
         dist_Rst := dist_Rt - 1;
         return;
      end if;
      test_6(s_set, s, t, bool);
      if bool then
         dist_Rt  := 3;
         dist_Rst := dist_Rt - 1;
         return;
      end if;
      distance_estimation(C1, s, t, Est);
      dist_Rst := Est;
   end procedure;


   function benefit(
      dist_Rt  : positive;
      dist_Rst : positive)
   return real is
   begin
      return real(dist_Rt-dist_Rst)*(10.0**(-dist_Rst));
   end function;


   procedure Hcub(
      variable C1    : in llist_access;
      variable r_set : in llist_access;
      variable s_set : in bst_access;
      s_node         : inout bst_node_access;
      variable t_set : in llist_access;
      dist_Rt        : in positive;
      bits           : inout natural;
      max            : inout real;
      solution       : inout natural)
   is
      variable dist_Rst_aux : positive;
      variable dist_Rt_aux : positive;
      variable sum : real := 0.0;
      variable bits_actual : positive;
      variable t_ite : llist_node_access := t_set.head;
   begin
      if s_node = null then
         solution := 0;
      else
         if s_node.left /= null then
            Hcub(C1, r_set, s_set, s_node.left, t_set, dist_Rt, bits, max, solution);
         end if;

         while t_ite /= null loop
            dist_Rt_aux := dist_Rt;
            distance(C1, r_set, s_set, s_node.value, t_ite.value, dist_Rt_aux, dist_Rst_aux);
            sum := sum + benefit(dist_Rt_aux, dist_Rst_aux);
            t_ite := t_ite.next_node;
         end loop;
         if sum > max then
            max := sum;
            solution := s_node.value;
            bits := min_bits(s_node.value);
         elsif sum = max then
            bits_actual := min_bits(s_node.value);
            if bits_actual < bits then
               bits := bits_actual;
               solution := s_node.value;
            end if;
         end if;

         if s_node.right /= null then
            Hcub(C1, r_set, s_set, s_node.right, t_set, dist_Rt, bits, max, solution);
         end if;
      end if;
   end procedure;

   procedure Hcub(
      variable C1    : in llist_access;
      variable r_set : in llist_access;
      variable s_set : in bst_access;
      variable t_set : in llist_access;
      dist_Rt        : in positive;
      solution       : out natural)
   is
      variable s_node : bst_node_access;
      variable max    : real := 0.0;
      variable bits   : natural := natural'high;
   begin
      if s_set.root /= null and r_set.head /= null and t_set.head /= null then
         s_node := s_set.root;
         Hcub(C1, r_set, s_set, s_node, t_set, dist_Rt, bits, max, solution);
      else
         solution := 0;
      end if;
   end procedure;

----------------------------------------------------------------------------------------------------

   procedure insert(
      graph             : inout vertex_access;
      variable new_node : in vertex_node_access)
   is
   begin
      if graph /= null then
         if new_node /= null then
            if graph.head = null then
               graph.head := new_node;
               graph.tail := new_node;
            else
               graph.tail.next_node := new_node;
               graph.tail := new_node;
            end if;
            graph.size := graph.size + 1;
         else
         msg_debug("insert<vertex_access, vertex_node_access> : null vertex_node_access");
         end if;
      else
         msg_debug("insert<vertex_access, vertex_node_access> : null vertex_access");
      end if;
   end procedure;

   --this procedure receives the fundamental to synthesize next and calculates the combination of the
   --previously synthesized fundamentals that result in the new one, and adds this information to a
   --vertex_node which is then returned
   procedure insert(
      vertex         : inout vertex_node_access;
      variable r_set : in llist_access;
      fundamental    : in positive)
   is
      variable ite1, ite2 : llist_node_access;
      variable aux : integer;
      variable exponent : natural;
   begin
      if vertex /= null then
         if r_set /= null then
            ite1 := r_set.head;
            while ite1 /= null loop
               ite2 := r_set.head;
                  while ite2 /= null loop
                     exponent := 0;
                     aux := 0;
                     while aux <= fundamental loop
                        aux := ite1.value*(2**exponent) - ite2.value;
                        if fundamental = aux then                     --u^exp-v=w
                           vertex.w  := fundamental;
                           vertex.u  := ite1.value;
                           vertex.v  := ite2.value;
                           vertex.l1 := exponent;
                           vertex.l2 := 0;
                           vertex.s  := true;
                           return;
                        elsif fundamental = abs(aux) then             --u-v^exp=w
                           vertex.w  := fundamental;
                           vertex.u  := ite2.value;
                           vertex.v  := ite1.value;
                           vertex.l1 := 0;
                           vertex.l2 := exponent;
                           vertex.s  := true;
                           return;
                        elsif fundamental = aux + 2*ite2.value then   --u^exp+v=w
                           vertex.w  := fundamental;
                           vertex.u  := ite1.value;
                           vertex.v  := ite2.value;
                           vertex.l1 := exponent;
                           vertex.l2 := 0;
                           vertex.s  := false;
                           return;
                        end if;
                        exponent := exponent + 1;
                     end loop;
                     ite2 := ite2.next_node;
                  end loop;
               ite1 := ite1.next_node;
            end loop;
         else
         msg_debug("insert(vertex_node_access, bst_access, positive) : bst_access is null");
         end if;
      else
         msg_debug("insert(vertex_node_access, bst_access, positive) : vertex_node_access is null");
      end if;
   end procedure;


   procedure synthesize(
      number         : in positive;
      variable r_set : in llist_access;
      variable s_set : in bst_access;
      t_set          : inout llist_access;
      w_set          : inout llist_access;
      solution_graph : inout vertex_access)
   is
      variable node : vertex_node_access;
   begin
      insert(w_set, number);        -- W <- W+{number}
      delete_value(t_set, number);  -- T <- T-{number}
      --create node with the vertex information and insert it into solution graph
      node := new vertex_node;
      insert(node, r_set, number);
      insert(solution_graph, node);
   end procedure;


   procedure synthesize1(
      solution_graph : inout vertex_access;
      t_set          : inout llist_access)
   is
      variable node : vertex_node_access;
   begin
      node := new vertex_node'(w => 1, u =>1, l1 =>0, v =>1, l2 => 0, s => true, next_node => null);
      insert(solution_graph, node);
      delete_value(t_set, 1);
   end procedure;


   procedure search_and_synthesize(
      variable r_set : in llist_access;
      s_set          : inout bst_access;
      t_set          : inout llist_access;
      w_set          : inout llist_access;
      solution_graph : inout vertex_access)
   is
      variable to_synth : llist_access := new llist;
      variable iter     : llist_node_access;
      variable t        : natural;
   begin
      if s_set /= null then
         if t_set /= null then
            if w_set /=  null then
               --save found values into a linked list
               iter := t_set.head;
               while iter /= null loop
                  t := iter.value;
                  search(s_set, t);
                  if t /= 0 then
                     insert(to_synth, t);
                  end if;
                  iter := iter.next_node;
               end loop;
               --synthesize the saved values
               iter := to_synth.head;
               if iter /= null then
                  while iter /= null loop
                     t := iter.value;
                     synthesize(t, r_set, s_set, t_set, w_set, solution_graph);
                     iter := iter.next_node;
                  end loop;
               end if;
            end if;
         end if;
      end if;
   end procedure;


   procedure generate_solution_file(
      variable solution_graph : in vertex_access)
   is
      file solution_output : text;
      variable current_line : line;
      variable ite : vertex_node_access;
   begin
      file_open(solution_output, FILE_PATH, WRITE_MODE);
      if solution_graph /= null then
         write(current_line, image(solution_graph.size) & LF);
         ite := solution_graph.head;
         while ite /= null loop
            write(current_line, image(ite.w));
            write(current_line, string'(" "));
            write(current_line, image(ite.u));
            write(current_line, string'(" "));
            write(current_line, image(ite.l1));
            write(current_line, string'(" "));
            write(current_line, image(ite.v));
            write(current_line, string'(" "));
            write(current_line, image(ite.l2));
            write(current_line, string'(" "));
            if ite.s then
               write(current_line, string'("0"));
            else
               write(current_line, string'("1"));
            end if;
            writeline(solution_output, current_line);
            ite := ite.next_node;
         end loop;
      end if;
      file_close(solution_output);
   end procedure;


----------------------------------------------------------------------------------------------------

   procedure VorPus(
      target : positive_v)
   is
-- possible use of hash table for search [variable successor_hash_table : bit_vector (1 to 2^(UPPER_BITS + 1)) := (others => '0');]
      variable C1 : llist_access := new llist'(null, null);
      variable dist_Rt : natural;

      variable target_set    : llist_access := new llist'(null, null);
      variable ready_set     : llist_access := new llist'(null, null);
      variable working_set   : llist_access := new llist'(null, null);
      variable successor_set : bst_access   := new bst'(0, null);

      variable first_iteration : boolean := true;
      variable t : natural;
      variable solution_graph : vertex_access := new vertex'(0, null, null);
   begin

      generateC1(C1);

      ----------------------------------------------------------------------------------------------
      --Voronenko -Püschel algorithm
      ----------------------------------------------------------------------------------------------
      insert(target_set, target);   --inserts all values in the input positive vector to the linked list target_set
      insert(ready_set, 1);
      insert(working_set, 1);
      insert(successor_set, 1);
      --synthesize value 1
      synthesize1(solution_graph, target_set);
      calculate_first_dist_Rt(C1, target_set, dist_Rt);
      msg_debug(image(MAX_TARGET));
      msg_debug(target_set, "target_set");
      msg_debug(working_set, "working_set");
      msg_debug(ready_set, "ready_set");
      msg_debug(successor_set, "successor_set");
      msg_debug(C1, "C1");

      t_loop:
      while target_set.head /= null loop

         --OPTIMAL PART
         while working_set.head /= null loop
            --R <- (R union W)
            union(ready_set, working_set);
            --S <- (S union A^*(R, W))-W
            if first_iteration then          --in the first iteration the values in the successor set are
               --the same as those in C^1, so we just copy them from the already existing C^1 list
               insert(successor_set, C1);
               delete_value(successor_set, 1);
               --balance the binary search tree
               dsw(successor_set, successor_set.size);
            else
               compute_d1_successors(successor_set, ready_set, working_set);
            end if;
            --W <- Ø
            empty(working_set);
            --for t € (S intersection T) synthesize(t)
            search_and_synthesize(ready_set, successor_set, target_set, working_set, solution_graph);
            first_iteration := false;
            msg_debug(target_set, "target_set");
            msg_debug(working_set, "working_set");
            msg_debug(ready_set, "ready_set");
            msg_debug(successor_set, "successor_set");
            msg_debug("dist_Rt = " & image(dist_Rt));
         end loop;

         --HEURISTIC PART
         if target_set.head /= null then
            Hcub(C1, ready_set, successor_set, target_set, dist_Rt, t);
            synthesize(t, ready_set, successor_set, target_set, working_set, solution_graph);
            update_dist_Rt(dist_Rt, C1, ready_set, successor_set, t, target_set);
            msg_debug(target_set, "target_set");
            msg_debug(working_set, "working_set");
            msg_debug(ready_set, "ready_set");
            msg_debug(successor_set, "successor_set");
            msg_debug(solution_graph, "solution graph");
            msg_debug("dist_Rt = " & image(dist_Rt));
         end if;
      end loop;
----------------------------------------------------------------------------------------------------

      generate_solution_file(solution_graph);

      msg_debug(successor_set, "successor_set");
      msg_debug(working_set, "working_set");
      msg_debug(ready_set, "ready_set");
      msg_debug(target_set, "target_set");
      msg_debug(string'("targets:"));
      msg_debug(target, ", ");
      msg_debug(solution_graph, "solution graph");

   end procedure;


end package body;