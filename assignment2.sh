#! /bin/bash

##################################################################################
# User defined function declarations
##################################################################################
cleanup()
{
	# Clean-up previous run temporary files
   rm -rf  group_by_fl.dat employee_col.lst preprocessed_employee.dat sorted_employee.dat
}

display()
{
	# Select * from Employee
	echo -e "*************** Employee Table ***************"
	sed 's/,/\t| /g' $master_employee_fl
	
	# Select * from Department
	echo -e "\n*************** Department Table ***************"
	sed 's/,/\t| /g' $master_dept_fl
}

nested_query()
{
	
	# Implementing the Nested Query functionality
	echo -e "\n\n*************** Nested Query Resultset >= Avg(`grep $agg_col employee_col.lst | awk -F':' '{print $2}'`) ***************\\n"
	
	# Create Header record for Join output
	head -1 $master_employee_fl | sed 's/,/\t| /g'
	
	case $agg_col in
        	1) sed 1d $master_employee_fl | awk -F',' -v avg_val=$avg '$1>=avg_val {print $0}' | sed 's/,/\t| /g';;
       	 	5) sed 1d $master_employee_fl | awk -F',' -v avg_val=$avg '$5>=avg_val {print $0}' | sed 's/,/\t| /g';;
        	9) sed 1d $master_employee_fl | awk -F',' -v avg_val=$avg '$9>=avg_val {print $0}' | sed 's/,/\t| /g';;
        	default) echo -e "Invalid aggeregate column specified !"
                	 exit 1;;
	esac
	
	# Call the main choice function
	sql_choice
}

aggregate()
{
	# Calculate the Minimum value [Min()]
	case $agg_col in
		1) min=$(head -1 group_by_fl.dat | awk -F',' '{print $1}') ;;
		5) min=$(head -1 group_by_fl.dat | awk -F',' '{print $5}') ;;
		9) min=$(head -1 group_by_fl.dat | awk -F',' '{print $9}') ;;
		default) echo -e "Invalid aggeregate column specified !"
                         exit 1;;
	esac

	# Calculate the Maximum value [Max()]
	case $agg_col in
		1) max=$(tail -1 group_by_fl.dat | awk -F',' '{print $1}') ;;
		5) max=$(tail -1 group_by_fl.dat | awk -F',' '{print $5}') ;;
		9) max=$(tail -1 group_by_fl.dat | awk -F',' '{print $9}') ;;
		default) echo -e "Invalid aggeregate column specified !"
			 exit 1;;
	esac

	# Calculate the number of instances [Count(*)]
	count=$(wc -l group_by_fl.dat | awk '{print $1}')

	# Calculate the Sum [Sum()]
	while IFS=',' read -r line
	do
		case $agg_col in
			1) ind_val=$(echo $line | awk -F',' '{print $1}') ;;
			5) ind_val=$(echo $line | awk -F',' '{print $5}') ;;
			9) ind_val=$(echo $line | awk -F',' '{print $9}') ;;
			default) echo -e "Invalid aggeregate column specified !"
   				 exit 1;;
		esac

		sum=$((sum+ind_val))
	done < group_by_fl.dat

	# Calculate the Avg [Avg()]
	avg=$((sum/count))
}

group_by()
{
	# Print the list of columns for specifying grouping condition
	echo -e "*************** Group By Criteria ***************"
	head -1 $master_employee_fl | awk -F',' '{for(i=1;i<=NF;i++) printf("%s: %s\n",i,$i)}' > employee_col.lst
	echo "0: For entire dataset as a single group (Nested Query)" >> employee_col.lst 
	cat employee_col.lst
	
	# Specify the grouping attribute/column
	echo -e "Please select a grouping column number : \c"
	read group_by
	
	echo -e "\nGrouping the Employee data on : `grep $group_by employee_col.lst | tr ':' ' -'` \n\n"
	
	
	# Specify the Aggregate attribute/column
	echo -e "*************** Aggergate Criteria ***************"
	grep -ie "id" -ie "sal" -ie "num" -ie "no"  employee_col.lst | grep -v $group_by
	
	echo -e "Please select a Aggregate function column number : \c"
	read agg_col
	
	echo -e "\nAggegating Employee data on : `grep $agg_col employee_col.lst | tr ':' ' -'` \n\n"
	
	
	if [ $group_by -eq 0 ]
	then
		# Sort the data in the Employee file based on the Aggregating column values
		sed 1d $master_employee_fl | sort -t ',' -k $agg_col -n -o group_by_fl.dat
	
		# Calculate the aggregate function values
		aggregate
	
		# Print the aggregate summary output
		echo -e "*************** Aggregate Summary Statistics Resultset ***************"
		echo -e "Column Name = `grep $agg_col employee_col.lst | awk -F':' '{print $2}'` \t Min = $min \t Max = $max \t Count = $count \t Sum = $sum \t Avg = $avg"
		
		if [ $oper -eq 2 ]
		then
			# Call the nested query function
			nested_query
		fi	
	else
		echo -e "*************** Aggergate Summary Statistics Resultset ***************"
	
		# Extract the list of unique values for grouping attribute/column
		uniq_val_arr=($(sed 1d $master_employee_fl | cut -d ',' -f $group_by | sort | uniq))
	
		# Loop through every element in the array to perform the Aggregate functionality
		for uniq_var in "${uniq_val_arr[@]}"
		do
			case $group_by in
				3) awk -F',' -v col_val=$uniq_var '$3==col_val {print $0}' $master_employee_fl | sort -t ',' -k $agg_col -n -o group_by_fl.dat ;;
				6) awk -F',' -v col_val=$uniq_var '$6==col_val {print $0}' $master_employee_fl | sort -t ',' -k $agg_col -n -o group_by_fl.dat ;;
				7) awk -F',' -v col_val=$uniq_var '$7==col_val {print $0}' $master_employee_fl | sort -t ',' -k $agg_col -n -o group_by_fl.dat ;;
				9) awk -F',' -v col_val=$uniq_var '$9==col_val {print $0}' $master_employee_fl | sort -t ',' -k $agg_col -n -o group_by_fl.dat ;;
				default) echo -e "Invalid group by clause !"
					exit 1;;
			esac
	
			# Calculate the aggregate function values
			aggregate
			
			# Print the aggregate summary output if the count is greater than one
			if [ $count -gt 1 ]
			then
			echo -e "Value = $uniq_var \t Min = $min \t Max = $max \t Count = $count \t Sum = $sum \t Avg = $avg"
			fi
			# Reset sum value for next iteration
			sum=0 
		done
	fi
		
	# Call the main choice function
	sql_choice
}

main_join()
{
	clear
	display
	
	echo -e "n\n*************** Join Types ***************\n1: Inner Join (also Natural Join in our example)\n2: Left Outer Join\n3: Anti Join\n"
	echo -e "Please select a Join type to be performed : \c"
	read join_type
	
	echo -e "\n\nJoining Employee relation with Department on Dept_id as Key as type ${join_type} join"
	
	# Order by Dept_id on Employee relation
	sed 1d $master_employee_fl | sort -t ',' -k 9 -n -o sorted_employee.dat
	
	# Create Header record for Join output
	if [ $join_type -ne 3 ]
	then
		paste $master_employee_fl $master_dept_fl | head -1 | sed 's/Dept_id//g' | sed -e 's/,/\t| /g'
	else	
		head -1 $master_employee_fl | sed 's/,/\t| /g'
	fi
	
	while IFS=',' read -r line
	do
		curr_dept_id=$(echo $line | awk -F',' '{print $9}')
		
		# Implementing Concept of caching results for better algorithmic efficiency
		if [[ ! -z $curr_dept_id && $prev_dept_id != $curr_dept_id ]]
		then
			lookup_rec=$(awk -F',' -v dept_id_val=$curr_dept_id '$1==dept_id_val {print $0}' $master_dept_fl)
			lkp_dept_name=$(echo $lookup_rec | awk -F',' '{print $2}')
			lkp_dept_loc=$(echo $lookup_rec | awk -F',' '{print $3}')
		fi
			
		if [ $join_type -eq 2 ] || [[ $join_type -eq 1 && ! -z $lookup_rec ]] 
		then
			echo "$line,$lkp_dept_name,$lkp_dept_loc" | sed 's/,/\t| /g'
		elif [[ $join_type -eq 3 && -z $lookup_rec ]]
		then
			echo "$line" | sed 's/,/\t| /g'
		fi
			
		prev_dept_id=curr_dept_id
	done < sorted_employee.dat
	
	# Call the main choice function
	sql_choice
}

sql_choice()
{
	echo -e "\n*************** SQL Operations ***************\n1: Group by & Aggregation\n2: Nested Query\n3: Join\nPress (e/E) to exit\n"
	echo -e "Please select a SQL operation to be performed : \c"
	read oper
	
	case $oper in
		1) group_by ;;
		2) group_by ;;
		3) main_join ;;
		e|E) cleanup 
			 exit 0 ;;
		default) echo "Invalid Choice !!"
				 sql_choice ;;		 
	esac
}
##################################################################################
# Mainline Processing starts here
##################################################################################
# Setting the script global parameters
##################################################################################

# Clean-up previous run temporary files
cleanup
clear

master_employee_fl=$PWD/employee.CSV
master_dept_fl=$PWD/department.CSV
sum=0

display
echo -e "\nDo you want to ignore Null's in the file [Y/N]?"
read null_ch
	
if [ $null_ch == "N"  ] || [ $null_ch == "n" ]
then
	sed -e 's/,,/,NULL,/g' -e 's/^,/NULL,/g' -e 's/,$/,NULL/g' $master_employee_fl > preprocessed_employee.dat
	master_employee_fl=$PWD/preprocessed_employee.dat
	
	# Display NULL replaced values
	display
fi

# Call the main choice function
sql_choice

#head -1 master_dept_fl | awk -F',' '{for(i=1;i<=NF;i++) printf("%s: %s\n",i,$i)}'
