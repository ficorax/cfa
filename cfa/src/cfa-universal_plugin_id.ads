--  MIT License
--
--  Copyright (c) 2021 Alexandre BIQUE
--  Copyright (c) 2025 Marek Kuziel
--
--  Permission is hereby granted, free of charge, to any person obtaining a copy
--  of this software and associated documentation files (the "Software"), to deal
--  in the Software without restriction, including without limitation the rights
--  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
--  copies of the Software, and to permit persons to whom the Software is
--  furnished to do so, subject to the following conditions:
--
--  The above copyright notice and this permission notice shall be included in all
--  copies or substantial portions of the Software.
--
--  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
--  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
--  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
--  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
--  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
--  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
--  SOFTWARE.

package CfA.Universal_Plugin_ID is

   --  Pair of plugin ABI and plugin identifier.
   --
   --  If you want to represent other formats please send us an update to the comment with the
   --  name of the abi and the representation of the ID.
   type CLAP_Universal_Plugin_ID is
      record
         ABI : Chars_Ptr;
         --  // The plugin ABI name, in lowercase and null-terminated.
         --  // eg: "clap", "vst3", "vst2", "au", ...

         ID  : Chars_Ptr;
         --  // The plugin ID, null-terminated and formatted as follows:
         --  //
         --  // CLAP: use the plugin id
         --  //   eg: "com.u-he.diva"
         --  //
         --  // AU: format the string like "type:subt:manu"
         --  //   eg: "aumu:SgXT:VmbA"
         --  //
         --  // VST2: print the id as a signed 32-bits integer
         --  //   eg: "-4382976"
         --  //
         --  // VST3: print the id as a standard UUID
         --  //   eg: "123e4567-e89b-12d3-a456-426614174000"
      end record;

end CfA.Universal_Plugin_ID;
