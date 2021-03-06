// TODO: generate this file
Compiler :: #import "Compiler";
#import "Basic";
#import "Text_File_Handler";
String :: #import "String";

main :: () {
    txt_file: Text_File_Handler;
    start_file(*txt_file, "imgui_sizes", "imgui_sizes.txt", "imgui_sizes");
    if txt_file.failed return;
    defer deinit(*txt_file);

    #import "imgui";

    // to force these things into the type table
    dummy1: IO;
    dummy2: ListClipper;
    dummy3: ImColor;
    dummy4: OnceUponAFrame;
    dummy5: PlatformIO;
    dummy6: TextBuffer;
    dummy7: ImDrawCornerFlags;
    dummy8: TextBuffer;
    dummy9: TextFilter = .{};

    allowed_missing: []string = .[
        "TextFilter"
    ];

    type_table := Compiler.get_type_table();
    any_did_warn := false;

    while true {
        line, found := consume_next_line(*txt_file);
        if !found break;

        runtime_size: s64 = -1;
        struct_name, rest := break_by_spaces(line);
        jai_name, cpp_size_in_bytes := break_by_spaces(rest);

        for type_table {
            if it.type != .STRUCT continue;
            type_name := (cast(*Type_Info_Struct)it).name;
            if type_name == jai_name {
                runtime_size = it.runtime_size;
                break;
            }
        }

        if runtime_size == -1 {
            print("couldn't find type '%' (jai=%) in type table!\n", struct_name, jai_name);
            allow_missing := false;
            for allowed_missing
                if it == jai_name
                    allow_missing = true;
            if !allow_missing
                exit(1);
        }

        sizes_do_not_match := runtime_size != -1 && runtime_size != string_to_int(cpp_size_in_bytes);
        any_did_warn |= sizes_do_not_match;

        warn_str := ifx sizes_do_not_match then "!!!!" else "";
        print("% size - cpp: %, jai: % %\n" , struct_name, cpp_size_in_bytes, runtime_size, warn_str);
    }

    if any_did_warn {
        print("error: sizes did not match!\n");
        exit(1);
    }
}
