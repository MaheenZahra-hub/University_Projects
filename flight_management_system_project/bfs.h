#ifndef BFS_H
#define BFS_H

#include <iostream>
#include <string>
#include <queue> 
#include <fstream>
#include <iomanip>

using namespace std;

const int MAX_AIRPORTS = 30; 

// Basic airport record stored in the graph
struct Airport {
    int id;
    string name;
    string city;
    string country;
    bool hasEmergency; 
};


class Graph {
private:
    int adj[MAX_AIRPORTS][MAX_AIRPORTS];    //adjacency matrix
    Airport airports[MAX_AIRPORTS];         // Airport records
    int numAirports;

    // Linear search: find index of airport by its name
    int getIndexByName(string name) {
        for (int i = 0; i < numAirports; i++) {
            if (airports[i].name == name) return i;
        }
        return -1;
    }

public:
    // Constructor resets counters + adjacency matrix
    Graph() {
        numAirports = 0;
        for (int i = 0; i < MAX_AIRPORTS; i++)
            for (int j = 0; j < MAX_AIRPORTS; j++)
                adj[i][j] = 0;
    }

    // Load airport data from a file
    void loadAirports(string filename) {
        ifstream inFile(filename);
        if (!inFile) { cout << "Warning: " << filename << " not found." << endl; return; }
        
        while (numAirports < MAX_AIRPORTS && inFile >> airports[numAirports].id 
               >> airports[numAirports].name 
               >> airports[numAirports].city 
               >> airports[numAirports].country 
               >> airports[numAirports].hasEmergency) {
            numAirports++;
        }
        inFile.close();
    }

    // Load route connections between airports
    void loadRoutes(string filename) {
        ifstream inFile(filename);
        if (!inFile) return;
        string uName, vName;          //uName=Source  vName=Destination
        while (inFile >> uName >> vName) {
            int u = getIndexByName(uName);
            int v = getIndexByName(vName);
            if (u != -1 && v != -1) adj[u][v] = 1; 
        }
        inFile.close();
    }

    // Perform BFS
    void planTrip(string startName, string endName) {
        int start = getIndexByName(startName);
        int end = getIndexByName(endName);

        if (start == -1 || end == -1) {
            cout << "  [Error] Invalid Airport Names. Check spelling." << endl;
            return;
        }

        bool visited[MAX_AIRPORTS] = {false};
        int distance[MAX_AIRPORTS]; 
        int parent[MAX_AIRPORTS];

        for(int i=0; i<MAX_AIRPORTS; i++) {
            distance[i] = -1;
            parent[i] = -1;
        }

        queue<int> q;
        visited[start] = true;
        distance[start] = 0;
        q.push(start);

        bool found = false;

        while (!q.empty()) {
            int u = q.front();
            q.pop();
            if (u == end) { found = true; break; }

            for (int v = 0; v < numAirports; v++) {
                if (adj[u][v] == 1 && !visited[v]) {     //does next node exist? have we visited?
                    visited[v] = true;
                    distance[v] = distance[u] + 1;
                    parent[v] = u;
                    q.push(v);
                }
            }
        }

        if (found) {    //table printing
            cout << "\n--- BFS Trip Plan ---" << endl;
            cout << left << setw(15) << "Airport" << setw(10) << "Stops" << setw(15) << "Parent" << endl;
            cout << "----------------------------------------" << endl;
            
            for(int i=0; i<numAirports; i++) {
                if(visited[i]) {
                    string pName = (parent[i] == -1) ? "-" : airports[parent[i]].name;
                    cout << left << setw(15) << airports[i].name 
                         << setw(10) << distance[i] 
                         << setw(15) << pName << endl;
                }
            }
            // Trace back path
            int path[MAX_AIRPORTS];
            int count = 0;
            int curr = end;
            while(curr != -1) {
                path[count++] = curr;      //save the node
                curr = parent[curr];       //move to the parent
            }
            cout << "\n  [Plan] Total Stops: " << distance[end] << endl;
            cout << "  [Route] ";
            for(int i = count - 1; i >= 0; i--) {
                cout << airports[path[i]].name;
                if(i > 0) cout << " -> ";
            }
            cout << endl;
        } else {
            cout << "  [Result] No route found." << endl;
        }
    }
};

#endif
