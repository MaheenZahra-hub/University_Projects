#ifndef BST_H
#define BST_H

#include <iostream>
#include <string>
#include <fstream>
#include <iomanip>   // For formatting output (tables)
#include <sstream>   // For parsing strings (e.g., "14:30")
#include <cmath>     // For math functions like round()
#include <queue> 

using namespace std;

// UTILITY CLASS
// Handles time validation and arrival time calculations
class TimeUtils {
public:
    // Checks if time is in HH:MM format
    static bool isValidTime(string timeStr) {
        if (timeStr.length() != 5) return false;         // Must be "HH:MM" (5 chars)
        if (timeStr[2] != ':') return false;             // Middle char must be colon
        // Check if all other chars are digits
        if (!isdigit(timeStr[0]) || !isdigit(timeStr[1]) || 
            !isdigit(timeStr[3]) || !isdigit(timeStr[4]))
             return false;

        stringstream ss(timeStr);
        int h, m; char sep;
        ss >> h >> sep >> m;    // Extract int, char, int
        return (h >= 0 && h <= 23 && m >= 0 && m <= 59);   // Logic check
    }

    // Computes arrival time with possible day overflow
    static string calculateArrival(string depTime, float durationHours) {
        if (!isValidTime(depTime)) return "Invalid";

        //parse departure time
        stringstream ss(depTime);
        int h, m; char sep;
        ss >> h >> sep >> m;

        //convert everything to minutes
        long totalDepMinutes = (h * 60) + m;
        long durationMinutes = round(durationHours * 60);   // round ensures 1.5h -> 90m
        long totalArrivalMinutes = totalDepMinutes + durationMinutes;

        //handle day rollover
        int daysLater = totalArrivalMinutes / 1440;    // 1440 mins in a day
        int remainingMinutes = totalArrivalMinutes % 1440;   //time on the clock

        //converting back to HH:MM
        int arrH = remainingMinutes / 60;
        int arrM = remainingMinutes % 60;

        //Format Output (e.g., "05:05 (+1 Day)")
        stringstream out;
        if (arrH < 10) out << "0";
        out << arrH << ":";
        if (arrM < 10) out << "0";
        out << arrM;
        if (daysLater > 0) out << " (+" << daysLater << " Day)";
        return out.str();
    }
};

// FLIGHT CLASS
// Flight represents a single flight record
class Flight {
private:
    int flightID;
    string destination;
    string departureTime; 
    float duration;       
    string status;

public:
    Flight() : flightID(0), destination(""), departureTime("00:00"), duration(0.0), status("") {}

    //parameterized constructor
    Flight(int id, string dest, string dep, float dur, string stat) 
        : flightID(id), destination(dest), departureTime(dep), duration(dur), status(stat) {}

    //getters
    int getID() const { return flightID; }
    string getDest() const { return destination; }
    string getDepTime() const { return departureTime; }
    float getDuration() const { return duration; }
    string getStatus() const { return status; }

    // Prints flight info with arrival time
    void display() const {
        string arrival = TimeUtils::calculateArrival(departureTime, duration);
        cout << left << setw(8) << flightID 
             << setw(15) << destination 
             << setw(10) << departureTime 
             << setw(10) << duration 
             << setw(20) << arrival
             << setw(12) << status << endl;
    }

    // Converts flight to a space-separated line for saving
    string toString() const {
        return to_string(flightID) + " " + destination + " " + departureTime + " " + to_string(duration) + " " + status;
    }
};

// BSTNODE CLASS
// Represents a node in the BST
struct BSTNode {
    Flight data;
    BSTNode* left;
    BSTNode* right;
    BSTNode(Flight f) : data(f), left(nullptr), right(nullptr) {}
};

//BST CLASS
// Binary Search Tree for managing flights
class BST {
private:
    BSTNode* root;

    // Recursive insertion
    void insertRec(BSTNode*& node, Flight f) {
        if (node == nullptr){
             node = new BSTNode(f);
        }
        else if (f.getID() < node->data.getID()){
             insertRec(node->left, f);
        }
        else if (f.getID() > node->data.getID()){
             insertRec(node->right, f);
        }
    }

    // Recursive search
    BSTNode* searchRec(BSTNode* node, int id) const {
        if (node == nullptr || node->data.getID() == id) return node;
        if (id < node->data.getID()) return searchRec(node->left, id);
        return searchRec(node->right, id);
    }

    // In-order traversal for sorted display
    void inorderRec(BSTNode* node) const {
        if (node) {
            inorderRec(node->left);
            node->data.display();
            inorderRec(node->right);
        }
    }

    // Finds smallest node (used in deletion function)
    BSTNode* minValueNode(BSTNode* node) {
        BSTNode* current = node;
        while (current && current->left != nullptr) current = current->left;
        return current;
    }

    // Recursive deletion
    BSTNode* deleteRec(BSTNode* root, int id) {
        if (root == nullptr) return root;
        //find the node
        if (id < root->data.getID()) root->left = deleteRec(root->left, id);
        else if (id > root->data.getID()) root->right = deleteRec(root->right, id);
        else {
            //node found
            //case1: one child or no child
            if (root->left == nullptr) {
                BSTNode* temp = root->right;
                delete root;
                return temp;    // Return the surviving child to be linked to parent
            } else if (root->right == nullptr) {
                BSTNode* temp = root->left;
                delete root;
                return temp;
            }

            //case2: two children
            BSTNode* temp = minValueNode(root->right);   //find inorder successor
            root->data = temp->data;   // Copy successor's data to this node
            root->right = deleteRec(root->right, temp->data.getID());   //delete original successor
        }
        return root;
    }

    // Saves BST in pre-order
    void saveRec(BSTNode* node, ofstream& outFile) {
        if (node) {
            outFile << node->data.toString() << endl;   //in Pre-Order 
            saveRec(node->left, outFile);
            saveRec(node->right, outFile);
        }
    }

public:
    BST() : root(nullptr) {}

    void insert(Flight f) { insertRec(root, f); }

    // Returns pointer to flight if found
    Flight* search(int id) const {
        BSTNode* res = searchRec(root, id);
        return res ? &(res->data) : nullptr;
    }

    void remove(int id) { root = deleteRec(root, id); }
    
    // Displays all flights sorted by ID
    void displayAll() const {
        if (!root) { cout << "  Database is empty." << endl; return; }
        cout << left << setw(8) << "ID" << setw(15) << "Dest" << setw(10) << "Dep" << setw(10) << "Dur(h)" << setw(20) << "Arrival" << setw(12) << "Status" << endl;
        cout << "---------------------------------------------------------------------------" << endl;
        inorderRec(root);
    }

    // LEVEL-WISE VISUALIZATION 
    void showTreeStructure() const {
        if (!root) { 
            cout << "BST Level-wise Display:\n(Empty)" << endl; 
            return; 
        }

        queue<pair<BSTNode*, int>> q;
        q.push({root, 0});

        cout << "\nBST Level-wise Display:" << endl;
        while (!q.empty()) {
            BSTNode* node = q.front().first;
            int level = q.front().second;
            q.pop();

            cout << "Level " << level << " : " << node->data.getID();
            
            // Handle Left Child
            cout << "  L:";
            if (node->left) {
                cout << node->left->data.getID();
                q.push({node->left, level + 1});
            } else {
                cout << "NULL";
            }

            // Handle Right Child
            cout << "  R:";
            if (node->right) {
                cout << node->right->data.getID();
                q.push({node->right, level + 1});
            } else {
                cout << "NULL";
            }
            cout << endl;
        }
        cout << endl;
    }

    // Restores BST from file
    void loadFromFile(string filename) {
        ifstream inFile(filename);
        if (!inFile) return;
        int id; string dest, dep, stat; float dur;
        while (inFile >> id >> dest >> dep >> dur >> stat) {
            if(TimeUtils::isValidTime(dep)) insert(Flight(id, dest, dep, dur, stat));
        }
        inFile.close();
    }

    // Saves BST to file
    void saveToFile(string filename) {
        ofstream outFile(filename);
        saveRec(root, outFile);
        outFile.close();
    }
};

#endif