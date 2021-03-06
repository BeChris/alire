with Alire.Containers;
with Alire.Errors;
with Alire.Utils.User_Input;

with Alr.Commands.Index;
with Alr.Root;

package body Alr.Commands.Update is

   -------------
   -- Execute --
   -------------

   overriding procedure Execute (Cmd : in out Command) is

      -------------------
      -- Parse_Allowed --
      -------------------

      function Parse_Allowed return Alire.Containers.Crate_Name_Sets.Set is
      begin
         return Set :  Alire.Containers.Crate_Name_Sets.Set do
            for I in 1 .. Num_Arguments loop
               Set.Include (+Argument (I));
            end loop;
         end return;
      exception
         when E : Alire.Checked_Error =>
            --  Bad crate names in the command line is an expected error, so
            --  re-raise it under the proper exception to avoid the 'unexpected
            --  error' message.
            Reportaise_Wrong_Arguments (Alire.Errors.Get (E));
            return Alire.Containers.Crate_Name_Sets.Empty_Set;
      end Parse_Allowed;

   begin
      Requires_Valid_Session (Sync => False);
      --  The user has explicitly requested an update, so it makes no sense to
      --  sync previously, or the update would never find changes.

      if Cmd.Online then
         Index.Update_All;
      end if;

      Requires_Full_Index;

      Root.Current.Update_Dependencies
        (Allowed => Parse_Allowed,
         Options => (Age    => Query_Policy,
                     others => <>),
         Silent  => Alire.Utils.User_Input.Not_Interactive);
   end Execute;

   ----------------------
   -- Long_Description --
   ----------------------

   overriding
   function Long_Description (Cmd : Command)
                              return Alire.Utils.String_Vector is
     (Alire.Utils.Empty_Vector
      .Append ("Resolves unpinned dependencies using available indexes.")
      .New_Line
      .Append ("Invoked without arguments will consider all unpinned crates"
               & " for updating.")
      .New_Line
      .Append ("One or more crates can be given as argument, in which case"
               & " only these crates will be candidates for updating."
               & " Requesting the update of a pinned crate is not allowed."));

   --------------------
   -- Setup_Switches --
   --------------------

   overriding procedure Setup_Switches
     (Cmd    : in out Command;
      Config : in out GNAT.Command_Line.Command_Line_Configuration)
   is
      use GNAT.Command_Line;
   begin
      Define_Switch
        (Config,
         Cmd.Online'Access,
         Long_Switch => "--online",
         Help        => "Fetch index updates before attempting crate updates");
   end Setup_Switches;

end Alr.Commands.Update;
