#!/usr/bin/env python3
import cairo, sys, os

def generate_title(title_text, output_dir):
    os.makedirs(output_dir, exist_ok=True)
    
    # Calculate dimensions
    # Estimate width based on character count
    char_count = len(title_text) + 4 # for '>_ ' and cursor
    w = max(420, min(800, char_count * 15 + 60))
    h = 44
    radius = 22
    
    for frame in range(36):
        surface = cairo.ImageSurface(cairo.FORMAT_ARGB32, w, h)
        ctx = cairo.Context(surface)
        ctx.set_antialias(cairo.ANTIALIAS_BEST)
        
        # 1. Dark frosted pill badge (deep obsidian crimson)
        ctx.new_sub_path()
        ctx.arc(w - radius, radius, radius - 1, -1.570796, 0)
        ctx.arc(w - radius, h - radius, radius - 1, 0, 1.570796)
        ctx.arc(radius, h - radius, radius - 1, 1.570796, 3.14159)
        ctx.arc(radius, radius, radius - 1, 3.14159, 4.71239)
        ctx.close_path()
        
        ctx.set_source_rgba(0.06, 0.01, 0.02, 0.85)
        ctx.fill_preserve()
        ctx.set_source_rgba(0.85, 0.12, 0.22, 0.45)
        ctx.set_line_width(1.5)
        ctx.stroke()
        
        # 2. Terminal Text
        ctx.select_font_face('Monospace', cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_BOLD)
        ctx.set_font_size(15)
        
        # Prefix: '>_ ' in vibrant maple/crimson
        prefix = '>_ '
        ctx.set_source_rgba(1.0, 0.25, 0.35, 0.95)
        ctx.move_to(22, 28)
        ctx.show_text(prefix)
        prefix_ext = ctx.text_extents(prefix)
        
        # User Title
        ctx.set_source_rgba(0.96, 0.92, 0.92, 0.98)
        ctx.move_to(22 + prefix_ext.x_advance, 28)
        ctx.show_text(title_text)
        title_ext = ctx.text_extents(title_text)
        
        # Blinking Terminal Cursor (Frames 0-17 visible, 18-35 hidden)
        if frame < 18:
            cursor_x = 22 + prefix_ext.x_advance + title_ext.x_advance + 4
            ctx.set_source_rgba(1.0, 0.2, 0.3, 0.95)
            ctx.rectangle(cursor_x, 14, 9, 18)
            ctx.fill()
            
        out_file = os.path.join(output_dir, f'title-{frame}.png')
        surface.write_to_png(out_file)

if __name__ == '__main__':
    title = sys.argv[1] if len(sys.argv) > 1 and sys.argv[1] else 'JOSEPH // SOFTWARE ARCHITECT'
    out_dir = sys.argv[2] if len(sys.argv) > 2 else '/home/joseph/Desktop/grub_modify/theme_pack/plymouth'
    generate_title(title, out_dir)
    print(f'Successfully generated 36 developer title frames for: "{title}"')
