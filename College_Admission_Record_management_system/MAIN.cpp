#include<iostream>
#include<fstream>
#include<string>
#include<cmath>
#include<cstring> //not using it
#include<iomanip>

using namespace std;

const int MAX_STUDENTS=100;                 //defines a fixed size for arrays
string studentNames[MAX_STUDENTS];
double studentMatric[MAX_STUDENTS];
double studentInter[MAX_STUDENTS];
int studentIDs[MAX_STUDENTS];
string studentDeps[MAX_STUDENTS];
string studentCNICs[MAX_STUDENTS];
double studentMerits[MAX_STUDENTS];         // for ranking
int totalStudents=0;                        //keeps track of how many students have been registered

class Person                               //base class for 'Student' and 'Admin'
{
	protected:
		string name;
		string cnic;
	public:
		Person()
		{
			name=" ";
			cnic=" ";
		}
		Person(string n,string c)
		{
			name=n;
			cnic=c;
		}
		
		virtual void displayinfo()=0;  //pure virtual function
		
		~Person()
		{
		}
};

class Student:public Person               //derived class of 'Person'
{
  protected: 
  
  int studentId;
  string dep;
  double intermarks;
  double matricmarks;
  public:
  	
  Student()
  {
  	studentId=0;
  	dep=" ";
  }
  
  Student(int i,string d,double ii,double m,string n,string c)
  {
  	studentId=i;
  	dep=d;
  	intermarks=ii;
  	matricmarks=m;
  	name=n;         //inherited from 'Person'
  	cnic=c;        //inherited from 'Person'
  }	
  
  void displayinfo() override 
  {
  	cout<<" Student Name:"<<name<<endl;
  	cout<<"Student CNIC:"<<cnic<<endl;
  	cout<<"Student ID:"<<studentId<<endl;
  	cout<<"Student Department:"<<dep<<endl;
  	cout<<"Students Inter Marks:"<<intermarks<<"/1200"<<endl;
  	cout<<"Students Matric Marks:"<<matricmarks<<"/1100"<<endl;
  }
  
  double calculateMerit() 
  {
    return (matricmarks / 1100.0 * 40) + (intermarks / 1200.0 * 60);
 }
  
  ~Student()
  {
  }
  
};

class Admin:public Person                //derived class of 'Person'
{
	private:
		int adminId;
	public:
	
	Admin()
	{
	  adminId=0;	
	}	
	
	Admin(int i, string n, string c)
	{
		adminId=i;
		name=n;         //inherited from 'Person'
		cnic=c;         //inherited from 'Person'
	}
	
	void displayinfo() override
	{
		cout<<"Admin name:"<<name<<endl;
		cout<<"Admin CNIC:"<<cnic<<endl;
		cout<<"Admin ID:"<<adminId<<endl;
	}
	
	~Admin()
	{
		
	}
};

class College             //is a container for tracking the total number of student admissions
{
	public:	
	static int totalAdmissions;
	
	static void showTotalAdmissions()
	{
		cout<<"Total Admissions:"<<totalAdmissions<<endl;
	}
};
int College::totalAdmissions=0;


class Admission:public Student                 //derived from 'Student'
//register new students via newAdmission() method
{
	public:
    void newAdmission()
    {
	cout << "Welcome to register new student" << endl;
	cout << "Enter Student name: ";
	cin.ignore();        //clears leftover characters
	getline(cin,name);   //reads a full line of input, including spaces, and stores it
	cout << "\nEnter Student CNIC without dashes: ";
	cin >> cnic;
	cout << "\nEnter Student ID: ";
	cin >> studentId;
	cout << "\nEnter department name: ";
	cin.ignore();
	getline(cin,dep);
	cout << "\nEnter Inter Marks out of 1200: ";
	cin >> intermarks;
	if (intermarks <= 1200 && intermarks >= 0)
	{
		cout<<"\nEnter Matric Marks out of 1100:";
		cin>>matricmarks;
		if(matricmarks<=1100&&matricmarks>=0)
		{
		College::totalAdmissions++;
           //STORE IN FILE
		ofstream outFile("studentx.txt", ios::app);      //Opens the file in append mode
		//ios::app will New data will be added at end of file and existing data is not overwritten
		if (outFile.is_open())
		{
			outFile << "Name:" << name << endl;
			outFile << "CNIC:" << cnic << endl;
			outFile << "Student ID:" << studentId << endl;
			outFile << "Department:" << dep << endl;
			outFile << "Inter Marks:" << intermarks << "/1200" << endl;
			outFile<<"Matric Marks:"<<matricmarks<<"/1100"<<endl;
			outFile << "-------------------------------" << endl;
			outFile.close(); //closes file after writing
			cout << "Registration Recorded" << endl;
		}
        else
	    {
			cout << "Unable to register Student." << endl;
	    }
	//The student data is stored in arrays temporarily, and also saved in a file for permanent storage

	    // STORE IN ARRAYS
    if (totalStudents < MAX_STUDENTS)
   {
    studentNames[totalStudents] = name;
    studentInter[totalStudents] = intermarks;
    studentMatric[totalStudents] = matricmarks;
    studentIDs[totalStudents] = studentId;
    studentDeps[totalStudents] = dep;

    // calculate merit and store
    double merit = (matricmarks / 1100.0 * 40.0) + (intermarks / 1200.0 * 60.0);
    studentMerits[totalStudents] = merit;

    totalStudents++;
   } 
	    }
	    else
		{
			cout<<"Invalid marks entered";
		}
	}
	else
	{
		cout << "Invalid information" << endl;
	}
}
		
};
// reads and displays all student records
void viewAllStudents()
{
	ifstream inFile("studentx.txt"); //opening file
	//Uses 'ifstream' to read from the file and print each student's record
	if (inFile.is_open())
	{
		string line;
		cout<<"\n----All Students----\n";
		while(getline(inFile,line))  //loop that reads the file line by line
		{
			cout<<line<<endl; //print the file that was read
		}
		inFile.close();  //close the file
	}
	else
	{
		cout<<"No Student Records Found."<<endl;
	}
}

 //search for a student record by their CNIC
void searchByCNIC(const string& targetCNIC)
{
	ifstream inFile("studentx.txt"); //open file for reading
	if (!inFile.is_open())
	{
		cout << "Unable to open student file." << endl;
		return;
	}

	string line;                //stores each line read from the file
	bool found = false;         //becomes true when the CNIC is found
	bool insideBlock = false;   //tells the program to print the full record block once the CNIC is found

	while (getline(inFile, line))
	{
		if (line.find("CNIC:" + targetCNIC) != string::npos)
		//Checks if the current line contains the exact CNIC
		{
			found = true;
			insideBlock = true;
			cout << "\n--- Student Record Found ---\n";
		}

		if (insideBlock)
		//if CNIC is found, it prints every line after it (ID, marks, etc.)
		{
			cout << line << endl;
			if (line.find("-------------------------------") != string::npos) //stop printing when reach this part of std record
			{
				insideBlock = false;
			}
			//nops stands for "no position"
			//string::npos is used to check if a substring was NOT found in a string
		}
	}

	if (!found)
	{
		cout << "No student found with CNIC: " << targetCNIC << endl;
	}

	inFile.close(); //closes the file
} 

//MANAGES DEGREE PROGRAMS
class Degree
{
	public:
		
	Degree()
	{
		ofstream outFile("degreex.txt"); //open the file
		if(outFile.is_open())
		//write degree programs info in file then closes it
		{
			outFile<<"----All Degree Programs----";
			outFile<<"Degree Name: BSCS\nTotal Credit Hours:136\nTotal courses:42\nBSCS Focuses on programming and problem solving skills.\n";
			outFile<<"--------------------------------------------------------------------------------------------------------------\n";
			outFile<<"Degree Name: BBA\nTotal Credit Hours:132\nTotal courses:40\nBBA Focuses on marketing and management.\n";
			outFile<<"--------------------------------------------------------------------------------------------------------------\n";
			outFile<<"Degree Name:IT\nTotal Credit Hours:134\nTotal courses:41\nIT Focuses on networking and information security.\n";
			outFile<<"--------------------------------------------------------------------------------------------------------------\n";
			outFile<<"Degree Name:English Literature\nTotal Credit Hours:130\nTotal courses:40\nEnglish Literature focuses on english languages depth.\n";
			outFile<<"--------------------------------------------------------------------------------------------------------------\n";
			outFile.close();
		}
	}
	
	void viewDegrees()
	//Each line read from the file is printed to the console
	{
		ifstream inFile("degreex.txt"); //open the file
		if(inFile.is_open())
		{
			string line;
			cout<<"\n ---- Available Degree Programs ----\n";
			while(getline(inFile,line)) //
			{
				cout<<line<<endl;
			}
			inFile.close();
		}
		else
		{
			cout<<"Degree file not found"<<endl;
		}
	}
	
	~Degree()
	{
	}
};

class saverecords:public Student,public Degree    //inherits both 'Student' and 'Degree'(multiple inheritance)
{
  public:
  	void studenttt() //save std record manually
  	{
  		cout<<"Enter Record to be saved";
  		cout << "Enter Student name: ";
	    getline(cin,name);
	    cout << "\nEnter Student CNIC without dashes: ";
	    cin >> cnic;
	    cout << "\nEnter Student ID: ";
	    cin >> studentId;
    	cout << "\nEnter department name: ";
    	cin.ignore();
    	getline(cin,dep);
    	cout << "\nEnter Inter Marks out of 1200: ";
	    cin >> intermarks;
	    if (intermarks <= 1200 && intermarks >= 0)
	   {
		cout<<"\nEnter Matric Marks out of 1100:";
		cin>>matricmarks;
		if(matricmarks<=1100&&matricmarks>=0)
		{
		College::totalAdmissions++;
		
		ofstream outFile("studentx.txt", ios::app);
		if (outFile.is_open())
		{
			outFile << "Name:" << name << endl;
			outFile << "CNIC:" << cnic << endl;
			outFile << "Student ID:" << studentId << endl;
			outFile << "Department:" << dep << endl;
			outFile << "Inter Marks:" << intermarks << "/1200" << endl;
			outFile<<"Matric Marks:"<<matricmarks<<"/1100"<<endl;
			outFile << "-------------------------------" << endl;
			outFile.close();
			cout << "Record Saved Sucessfully" << endl;
		}
        if (totalStudents < MAX_STUDENTS)
   {
    studentNames[totalStudents] = name;
    studentInter[totalStudents] = intermarks;
    studentMatric[totalStudents] = matricmarks;
    studentIDs[totalStudents] = studentId;
    studentDeps[totalStudents] = dep;

    // calculate merit and store
    double merit = (matricmarks / 1100.0 * 40.0) + (intermarks / 1200.0 * 60.0);
    studentMerits[totalStudents] = merit;

    totalStudents++;
   }  
        else
	    {
			cout << "Unable to Save Record." << endl;
	    }
	    }
	    else
		{
			cout<<"Invalid marks entered";
		}
	}
	else
	{
		cout << "Invalid information" << endl;
	}
   }
   
   void degreee()  //add new degree program manually
   {
   	string dname,purpose;
   	int credhr,courses;
   	        cin.ignore();
   		    cout<<"Enter New Degree Record";
			cout<<"Enter New Degree Name:";
			getline(cin,dname);
			cout<<"Enter New Degree Credit Hours:";
			cin>>credhr;
			cin.ignore();
			cout<<"Enter New Degrees Courses:";
			cin>>courses;
			cin.ignore();
			cout<<"Enter the objective of the new Degree Program:";
			getline(cin,purpose);
			
   	        ofstream outFile("degreex.txt",ios::app);
		     if(outFile.is_open())
		     {
		     	outFile<<"Degree Name:"<<dname;
		     	outFile<<"\nTotal Credit Hours:"<<credhr;
		     	outFile<<"\nTotal Courses:"<<courses;
		     	outFile<<"\n"<<purpose;
		     	outFile<<"--------------------------------------------------------------------------------------------------------------\n";
		     	outFile.close();
             }
    }
};
  
  //generates and displays a merit list of students
  void generateMeritList() {
    if (totalStudents == 0) {
        cout << "No student records to display.\n";
        return;
    }

    // Sorting based on merit (Bubble Sort)
    for (int i = 0; i < totalStudents - 1; ++i) {
        for (int j = 0; j < totalStudents - i - 1; ++j) {
            if (studentMerits[j] < studentMerits[j + 1]) {
                swap(studentMerits[j], studentMerits[j + 1]);
                swap(studentNames[j], studentNames[j + 1]);
                swap(studentCNICs[j], studentCNICs[j + 1]);
                swap(studentDeps[j], studentDeps[j + 1]);
                swap(studentIDs[j], studentIDs[j + 1]);
            }
        }
    //BUBBLE SORT explanation
// Bubble Sort to sort students based on merit in descending order:
// It repeatedly steps through the list, compares adjacent merit values,
// and swaps them if they are in the wrong order (lower merit before higher merit).
// This process is repeated until the whole list is sorted,
// with the highest merit students “bubbling up” to the front of the array.

    }

    // Displaying Merit List
	//printsa the header for the merit list
    cout << "\n==================== MERIT LIST ====================\n";
    cout << left << setw(5) << "No." 
         << setw(20) << "Name" 
         << setw(15) << "CNIC" 
         << setw(10) << "ID" 
         << setw(20) << "Department" 
         << setw(10) << "Merit (%)" << endl;
    cout << "----------------------------------------------------\n";
	//left = aligns the text to the left within the given width
	//setw(x)= sets the width of the field to x characters (like column width).
 
	//loop to print each std data
    for (int i = 0; i < totalStudents; ++i) {
        cout << left << setw(5) << (i + 1)
             << setw(20) << studentNames[i]
             << setw(15) << studentCNICs[i]
             << setw(10) << studentIDs[i]
             << setw(20) << studentDeps[i]
             << setw(10) << fixed << setprecision(2) << studentMerits[i] << endl;
    }

    cout << "====================================================\n";
}


int main()
{
	Degree d;          // Creates an object to access/view degree programs
	int choice;        // Stores user's menu choice
	saverecords s;     // Object to handle saving data to files
	do
	{
		cout<<"----WELCOME TO COLLEGE ADMISSION AND RECORD MANAGEMENT SYSTEM----"<<endl;
		cout<<"1. Register New Student\n2. View All Students\n3. View Degree Programs\n4. Search Student by CNIC\n5. Generate Merit List\n6. Save Records to File\n7. Load Records from File\n8.Exit"<<endl;
		cout<<"Enter Your Choice:";
		cin>>choice;
		switch (choice)
		{
			case 1: {
				Admission a;        // Create Admission object
				a.newAdmission();   // Register new student
				break;
			}
			case 2: {
				viewAllStudents();  // Displays all registered students
				break;
			}
			case 3:{
				d.viewDegrees();    // Use Degree object to show all degree programs
				break;
			}
			case 4:{
				string searchCnic;
				cout<<"Enter CNIC to Search without dashes:";
				cin>>searchCnic;
				searchByCNIC(searchCnic);   // Find and show student matching that CNIC
				break;
			}
			case 5:{
				generateMeritList();       // Sort and show students based on merit
				break;
			}
			case 6:{ //save records to file
				int choicee;
				cout<<"To which file do you want to save records to: 1. Student, 2. Degree";
				cin>>choicee;
				cin.ignore();
				if(choicee==1)
				{
					s.studenttt();    // Save student records
				}
				else if(choicee==2)
				{
					cin.ignore();
					s.degreee();     // Save degree records
				}
				else
				{
					cout<<"Invalid choice";
				}
				break;
		    }
		    case 7:{
		    	cout<<"LOADING ALL RECORDS\n";
		    	cout<<"STUDENT FILE RECORDS:";
		    	viewAllStudents();  //show students
		    	cout<<"\nDEGREE FILE RECORDS:";
		    	d.viewDegrees();    //show degrees
		    	cout<<"\nFILES LOADED SUCCSESSFULLY";
				break;
			}

		}
	} while(choice!=8);


}
