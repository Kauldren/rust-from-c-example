#[no_mangle]
pub extern fn kmain() {
	unsafe {
		*((0xb800u) as *mut u16) = 0 as u16;	
	}
}
