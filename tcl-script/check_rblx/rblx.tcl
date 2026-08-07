set path "C:\\Users\\thien\\AppData\\Local\\Roblox\\LocalStorage"

cd $path

proc isProcessRunning {processName} {
	if {[catch {exec tasklist /FI "IMAGENAME eq $processName"} result]} {
		return 0
	}

	return [string match "*$processName*" $result]
}

proc deleteFile {processName} {

	set counter 0
	while {1} {
		

		if {[isProcessRunning $processName]} {
			puts "Process is running"
		} else {
			puts "Process is not running"
			after 5000
			continue
		}

		incr counter 1
		puts "Trying to delete files... attempt: $counter"


		foreach file [glob -nocomplain -type f *] {
			puts "file exists: $file"

			if {$file eq "RobloxCookies.dat" || $file eq "appStorage.json"} {
				puts "Deleting $file"
				file delete -force $file
			}

			after 1000
		}

		after 1000
	}	
}

deleteFile "RobloxPlayerBeta.exe"
