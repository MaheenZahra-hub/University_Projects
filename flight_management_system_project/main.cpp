#include <iostream>
#include <string>
#include <chrono>   // Used for the stopwatch in Case 6
#include <limits>   // Used to help clear input buffers
#include "bst.h"
#include "avl.h"
#include "bfs.h"
#include "stack.h" 

using namespace std;

// Helper function: Cleans up the input stream.
// If a user types text when we expect a number, this fixes the "infinite loop" error.
void clearInput() {
    cin.clear();
    cin.ignore(numeric_limits<streamsize>::max(), '\n');
}

int main() {
    // 1. Initialize our main data structures
    BST flightBST;       // Standard Binary Search Tree
    AVL flightAVL;       // Self-balancing AVL Tree
    Graph tripGraph;     // Graph for airport connections
    FlightStack undoStack; // Stack to hold deleted flights (for the Undo feature)

    // 2. Load data from text files immediately so the system isn't empty on startup
    cout << "Loading System..." << endl;
    flightBST.loadFromFile("flights.txt");
    flightAVL.loadFromBSTData("flights.txt");
    tripGraph.loadAirports("airports.txt");
    tripGraph.loadRoutes("routes.txt");
    cout << "Initialization Complete.\n" << endl;

    int choice = 0;
    
    // 3. The Main Menu Loop - keeps running until the user chooses to Exit (10)
    while (choice != 10) { 
        cout << "\n========================================" << endl;
        cout << "      FLIGHT MANAGEMENT SYSTEM" << endl;
        cout << "========================================" << endl;
        cout << "1. Add New Flight" << endl;
        cout << "2. Search Flight" << endl;
        cout << "3. Delete Flight" << endl;
        cout << "4. Display Flights in BST" << endl;
        cout << "5. Display Flights in AVL" << endl;
        cout << "6. Compare Search Time" << endl;
        cout << "7. Plan Your Trip" << endl;
        cout << "8. Show Tree Visualization" << endl; 
        cout << "9. Undo Last Delete" << endl;        
        cout << "10. Exit" << endl;
        cout << "========================================" << endl;
        cout << "Enter Choice: ";
        
        // Input validation for the menu choice itself
        if (!(cin >> choice)) {
            cout << "Invalid input. Numbers only." << endl;
            clearInput();
            continue; // Jump back to the start of the loop
        }

        switch (choice) {
            case 1: { 
                // --- ADD NEW FLIGHT ---
                // We use local variables here to hold data before creating the object
                int id; 
                string dest, status, depTime; 
                float dur;

                // Validation Loop 1: Flight ID
                // We keep asking until we get a number that DOESN'T already exist.
                while (true) {
                    cout << "Enter Flight ID (Numeric_Value_Only): ";
                    if (cin >> id) {
                        // Check if this ID is already in our database
                        if (flightBST.search(id) != nullptr) {
                            cout << "Error: ID already exists!\n";
                        } else {
                            break; // ID is unique and valid, exit the loop
                        }
                    } else {
                        cout << "Error: Numbers only please.\n"; clearInput();
                    }
                }
                
                cin.ignore(); // Clear the enter key left in the buffer

                // Validation Loop 2: Destination
                // Ensure they don't leave it blank.
                while (true) {
                    cout << "Enter Destination (e.g. New York): ";
                    getline(cin, dest);
                    if (!dest.empty()) break;
                    cout << "Error: Destination cannot be empty.\n";
                }
                
                // Validation Loop 3: Time Format
                // Uses the helper in bst.h to check for HH:MM format
                while (true) {
                    cout << "Enter Departure Time (Hours:Mins): "; cin >> depTime;
                    if (TimeUtils::isValidTime(depTime)) break;
                    cout << "Error: Invalid format. Use 00:00 to 23:59 format please.\n";
                }

                // Validation Loop 4: Duration
                // Flights can't have negative duration!
                while (true) {
                    cout << "Enter Duration (Hours): ";
                    if (cin >> dur && dur > 0) break;
                    cout << "Error: Positive numbers only.\n"; clearInput();
                }

                // Validation Loop 5: Status
                // Force specific status strings to keep data consistent
                while(true) {
                    cout << "Enter Status (On-time/Delayed/Cancelled): "; cin >> status;
                    if(status == "On-time" || status == "Delayed" || status == "Cancelled") break;
                    cout << "Error: Wrong Input. Please Check Spelling.\n";
                }

                // Finally, create the object and add it to BOTH trees
                Flight f(id, dest, depTime, dur, status);
                flightBST.insert(f);
                flightAVL.insert(f);
                cout << "[Success] Flight has been Added.\n";
                break;
            }

            case 2: { 
                // --- SEARCH FLIGHT ---
                int id;
                cout << "Enter Flight ID: ";
                if(cin >> id) {
                    // We search the BST (logic is same for AVL, so searching one is enough)
                    Flight* f = flightBST.search(id);
                    if (f) { 
                        cout << "\n--- Flight Details ---\n";
                        cout << left << setw(8) << "ID" << setw(15) << "Dest" << setw(10) << "Dep" << setw(10) << "Dur" << setw(20) << "Arrival" << setw(12) << "Status" << endl;
                        f->display(); 
                    } else cout << "Flight not found.\n";
                } else clearInput();
                break;
            }

            case 3: { 
                // --- DELETE FLIGHT (With Safety Net) ---
                int id;
                cout << "Enter Flight ID to delete: ";
                if(cin >> id) {
                    Flight* target = flightBST.search(id);
                    if (target) {
                        // CRITICAL: Before we delete, save a copy to the stack!
                        // This allows the "Undo" feature to work later.
                        undoStack.push(*target);
                        
                        // Now it's safe to remove from both trees
                        flightBST.remove(id);
                        flightAVL.remove(id); 
                        cout << "[Success] Flight " << id << " is deleted\n";
                    } else {
                        cout << "Error: Flight ID not found.\n";
                    }
                } else clearInput();
                break;
            }

            case 4: flightBST.displayAll(); break; // Shows the unbalanced tree
            case 5: flightAVL.display(); break;    // Shows the balanced tree

            case 6: { 
                // --- PERFORMANCE COMPARISON ---
                // This is a "drag race" between BST and AVL to see who finds data faster.
                int id;
                cout << "Enter Flight ID to search: "; 
                if(!(cin >> id)) { clearInput(); break; }

                // 1. Time the BST
                auto start = chrono::high_resolution_clock::now();
                flightBST.search(id);
                auto end = chrono::high_resolution_clock::now();
                auto bstTime = chrono::duration_cast<chrono::nanoseconds>(end - start).count();

                // 2. Time the AVL
                start = chrono::high_resolution_clock::now();
                flightAVL.search(id);
                end = chrono::high_resolution_clock::now();
                auto avlTime = chrono::duration_cast<chrono::nanoseconds>(end - start).count();

                // 3. Display stats
                cout << "\nEfficiency Results are following:- \n";
                cout << "BST Time: " << bstTime << " ns\n";
                cout << "AVL Time: " << avlTime << " ns\n";
                
                cout << ">>> VERDICT: ";
                if (avlTime < bstTime) cout << "AVL is faster (Balanced structure is helping).\n";
                else if (bstTime < avlTime) cout << "BST is faster (Node likely near the root).\n";
                else cout << "Both are equal.\n";
                break;
            }

            case 7: { 
                // --- BFS TRIP PLANNING ---
                string start, end;
                cin.ignore(); // Clear any leftover newlines
                cout << "Start Airport: "; getline(cin, start);
                cout << "End Airport: "; getline(cin, end);
                
                if(start.empty() || end.empty()) cout << "Error: Names cannot be empty.\n";
                else tripGraph.planTrip(start, end); // Calculate the shortest path (stops)
                break;
            }

            case 8: { 
                // --- VISUALIZATION ---
                // Displays the level-order (BFS) view of the trees we added earlier
                flightBST.showTreeStructure();
                flightAVL.showTreeStructure();
                break;
            }

            case 9: { 
                // --- UNDO FUNCTION ---
                if (undoStack.isEmpty()) {
                    cout << "Undo Stack is empty!\n";
                } else {
                    // Pop the last deleted flight from the stack...
                    Flight restored = undoStack.pop();
                    // ...and put it back into the live system.
                    flightBST.insert(restored);
                    flightAVL.insert(restored);
                    cout << "[Undo Done] Restored Flight ID: " << restored.getID() << endl;
                }
                break;
            }

            case 10: 
                // --- SAVE AND EXIT ---
                // Save the BST data back to the file so we don't lose changes.
                flightBST.saveToFile("flights.txt");
                cout << "Data Saved. Exiting...\n";
                break;

            default: cout << "Invalid choice.\n";
        }
    }
    return 0;
}