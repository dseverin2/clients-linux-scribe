corner_r=0
bg_colour=0x000000
ln_colour=0xffffff
bg_alpha=0.6
 
require 'cairo'
function rgb_to_r_g_b(colour,alpha)
	return ((colour / 0x10000) % 0x100) / 255., ((colour / 0x100) % 0x100) / 255., (colour % 0x100) / 255., alpha
end
 
function conky_draw_bg()
	if conky_window==nil then return end
	local w=conky_window.width
	local h=conky_window.height
	local cs=cairo_xlib_surface_create(conky_window.display, conky_window.drawable, conky_window.visual, w, h)
	cr=cairo_create(cs)
 
	cairo_move_to(cr,corner_r,0)
	cairo_line_to(cr,w-corner_r,0)
	cairo_curve_to(cr,w,0,w,0,w,corner_r)
	cairo_line_to(cr,w,h-corner_r)
	cairo_curve_to(cr,w,h,w,h,w-corner_r,h)
	cairo_line_to(cr,corner_r,h)
	cairo_curve_to(cr,0,h,0,h,0,h-corner_r)
	cairo_line_to(cr,0,corner_r)
	cairo_curve_to(cr,0,0,0,0,corner_r,0)
	cairo_close_path(cr)
 	cairo_set_source_rgba(cr,rgb_to_r_g_b(bg_colour,bg_alpha))
	cairo_fill(cr)
	
	ln=cairo_create(cs)
	cairo_move_to(ln,315,10)
	cairo_line_to(ln,315,165)
	cairo_line_to(ln,316,165)
	cairo_line_to(ln,316,10)
	cairo_line_to(ln,315,10)
	cairo_close_path(ln)
 	cairo_set_source_rgba(ln,rgb_to_r_g_b(ln_colour,1))
	cairo_fill(ln)
	
	ln1=cairo_create(cs)
	cairo_move_to(ln1,550,10)
	cairo_line_to(ln1,550,165)
	cairo_line_to(ln1,551,165)
	cairo_line_to(ln1,551,10)
	cairo_line_to(ln1,550,10)
	cairo_close_path(ln1)
 	cairo_set_source_rgba(ln1,rgb_to_r_g_b(ln_colour,1))
	cairo_fill(ln1)
end