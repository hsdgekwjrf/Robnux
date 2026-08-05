The Doc of Robnux Kernel


Kernel version 0.2.0, alpha.1


Syscall APIs:

exec: args:{path:string,args:table} 
return code:number,reason:string

create_process: {path:string,name:string,args:table} 
return {pid:number,process:process,name:string}

get_process_table: nil 
return process_table:table

kill_process: pid:number 
return code:number,reason:string

fs_mk: {filename:string,dir:string} 
return 0

fs_rm: filepath:string 
return code:number,reason:string

fs_mkdir: {dirname:string,parentdir:string} 
return 0

fs_write: {filepath:string,text:string} 
return 0

fs_write_add: {filepath:string,text:string} 
return code:number,reason:string

fs_read: filepath:string
return code:number,reason:string/text:string

fs_lsdir: filepath:string
return code:number/names:table

dev_clearscreen: nil
return 0

dev_output: text:string
return 0

dev_getinput: nil
return text:string

fs_cp: {filepath:string,dir:string}
return code:number,reason:string

fs_getminpath: path:string
return minpath:string

fs_mv: {filepath:string,dir:string}
return code:number,reason:string

drv: {d_id:number,arg:*}
return code:string/result:*