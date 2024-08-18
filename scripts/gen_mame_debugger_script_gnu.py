# Parse linker map file symbol table and generate mame debugger script to add symbols as comments
# Pass output file to mame with -debugscript <scriptname>
# View comments in mame debugger with main menu Options > Comments (Ctrl+N)

import re

def parse_linker_map(file_path):
    with open(file_path, 'r') as file:
        lines = file.readlines()

    comment_table = {}
    parsing_memory_map = False

    for line_number, line in enumerate(lines, start=1):
        if 'Linker script and memory map' in line:
            parsing_memory_map = True
            continue
        if parsing_memory_map:
            if line.strip() == '':
                continue
            # Stop the loop if the line contains ".garbage"
            if '.garbage' in line:
                break
           # Updated regex to exclude lines that start with a text string
            match = re.match(r'^(?!.*\.o)\s*0x([0-9A-Fa-f]+)\s+(.+)', line)

            if match:
                address, comment = match.groups()
                comment_table[comment] = address
                #print(f'{line_number}: Address: {address} Comment: {comment}')

    return comment_table

def generate_mame_debugger_script(comment_table, output_path):
    with open(output_path, 'w') as file:
        for comment, address in comment_table.items():
            file.write(f'comadd {address},{comment}\n')
        # Set a breakpoint at the address of the 'main' symbol, if it exists
        if 'main' in comment_table:
            file.write(f'bpset {comment_table["main"]}\n')

def main():
    linker_map_path = 'build_gnu/ROM.map'  # Replace with your linker map file path
    output_script_path = 'build_gnu/mame_debugger_script_gnu.txt'  # Replace with desired output script path

    comment_table = parse_linker_map(linker_map_path)
    generate_mame_debugger_script(comment_table, output_script_path)

if __name__ == '__main__':
    main()
