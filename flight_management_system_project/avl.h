#ifndef AVL_H
#define AVL_H

#include "bst.h"
#include <queue> 

// Node structure for AVL tree: holds flight, children, and height for balancing
struct AVLNode {
    Flight data;
    AVLNode *left, *right;
    int height; // height of current node used for balance calculations
    AVLNode(Flight f) : data(f), left(nullptr), right(nullptr), height(1) {}
};

// Self-balancing AVL tree for storing flights
class AVL {
private:
    AVLNode* root;         // root of AVL tree
    int rotationCount;     // tracks how many rotations happened overall

    // Returns height safely (0 if null)
    int height(AVLNode* N) { return (N == nullptr) ? 0 : N->height; }

    // Helper max function
    int max(int a, int b) { return (a > b) ? a : b; }

    // Computes balance factor: left height - right height
    int getBalance(AVLNode* N) {
        if (N == nullptr) return 0;
        return height(N->left) - height(N->right);
    }

    // Performs right rotation around node y
    // Used when left-heavy
    AVLNode* rightRotate(AVLNode* y) {
        AVLNode* x = y->left;      // left child becomes new root
        AVLNode* T2 = x->right;    // store x's right subtree

        x->right = y;              // rotate
        y->left = T2;

        y->height = max(height(y->left), height(y->right)) + 1;
        x->height = max(height(x->left), height(x->right)) + 1;

        rotationCount++;           // track balancing activity
        return x;                  // x is new root of subtree
    }

    // Performs left rotation around node x
    // Used when right-heavy
    AVLNode* leftRotate(AVLNode* x) {
        AVLNode* y = x->right;     // right child becomes new root
        AVLNode* T2 = y->left;

        y->left = x;
        x->right = T2;

        x->height = max(height(x->left), height(x->right)) + 1;
        y->height = max(height(y->left), height(y->right)) + 1;

        rotationCount++;
        return y;                  // new subtree root
    }

    // Recursive insertion with AVL rebalancing
    AVLNode* insertRec(AVLNode* node, Flight f) {
        if (node == nullptr) return new AVLNode(f);

        // Normal BST insert
        if (f.getID() < node->data.getID()) node->left = insertRec(node->left, f);
        else if (f.getID() > node->data.getID()) node->right = insertRec(node->right, f);
        else return node; // duplicate IDs ignored

        // Update height
        node->height = 1 + max(height(node->left), height(node->right));

        // Check balance
        int balance = getBalance(node);

        // Case: Left-Left
        if (balance > 1 && f.getID() < node->left->data.getID())
            return rightRotate(node);

        // Case: Right-Right
        if (balance < -1 && f.getID() > node->right->data.getID())
            return leftRotate(node);

        // Case: Left-Right
        if (balance > 1 && f.getID() > node->left->data.getID()) {
            node->left = leftRotate(node->left);
            return rightRotate(node);
        }

        // Case: Right-Left
        if (balance < -1 && f.getID() < node->right->data.getID()) {
            node->right = rightRotate(node->right);
            return leftRotate(node);
        }

        return node;
    }

    // Finds minimum node in a subtree (in-order successor)
    AVLNode* minValueNode(AVLNode* node) {
        AVLNode* current = node;
        while (current->left != nullptr) current = current->left;
        return current;
    }

    // Recursive deletion + AVL rebalancing
    AVLNode* deleteRec(AVLNode* root, int id) {
        if (root == nullptr) return root;

        // Standard BST deletion
        if (id < root->data.getID()) root->left = deleteRec(root->left, id);
        else if (id > root->data.getID()) root->right = deleteRec(root->right, id);
        else {
            // Node with one or zero children
            if ((root->left == nullptr) || (root->right == nullptr)) {
                AVLNode* temp = root->left ? root->left : root->right;

                if (temp == nullptr) { // no children
                    temp = root;
                    root = nullptr;
                } else { // one child
                    *root = *temp; // copy child data
                }
                delete temp;
            } else {
                // Node with two children: replace with successor
                AVLNode* temp = minValueNode(root->right);
                root->data = temp->data;
                root->right = deleteRec(root->right, temp->data.getID());
            }
        }

        if (root == nullptr) return root;

        // Update height
        root->height = 1 + max(height(root->left), height(root->right));

        // Rebalance
        int balance = getBalance(root);

        // LL
        if (balance > 1 && getBalance(root->left) >= 0)
            return rightRotate(root);

        // LR
        if (balance > 1 && getBalance(root->left) < 0) {
            root->left = leftRotate(root->left);
            return rightRotate(root);
        }

        // RR
        if (balance < -1 && getBalance(root->right) <= 0)
            return leftRotate(root);

        // RL
        if (balance < -1 && getBalance(root->right) > 0) {
            root->right = rightRotate(root->right);
            return leftRotate(root);
        }

        return root;
    }

    // In-order traversal (shows sorted flights)
    void inorderRec(AVLNode* node) const {
        if (node != nullptr) {
            inorderRec(node->left);
            node->data.display();
            inorderRec(node->right);
        }
    }

    // Standard recursive BST search
    AVLNode* searchRec(AVLNode* node, int id) const {
        if (node == nullptr || node->data.getID() == id) return node;
        if (id < node->data.getID()) return searchRec(node->left, id);
        return searchRec(node->right, id);
    }

public:
    AVL() : root(nullptr), rotationCount(0) {}

    // Public insertion wrapper
    void insert(Flight f) { 
        root = insertRec(root, f);
     }

    // Public delete wrapper (only deletes if found)
    void remove(int id) {
         if (search(id)) 
         root = deleteRec(root, id); 
        }

    // Public search returns pointer to flight
    Flight* search(int id) const {
        AVLNode* res = searchRec(root, id);
        return res ? &(res->data) : nullptr;
    }

    // Display tree contents in sorted order
    void display() const {
        if (!root) { cout << "  AVL Tree is empty." << endl; return; }
        cout << left << setw(8) << "ID" << setw(15) << "Dest" << setw(10) << "Dep" << setw(10) << "Dur" << setw(20) << "Arrival" << setw(12) << "Status" << endl;
        cout << "---------------------------------------------------------------------------" << endl;
        inorderRec(root);
        cout << "\n  [Stats] Total Rotations performed: " << rotationCount << endl;
    }

    // Level-wise view to understand AVL structure
    void showTreeStructure() const {
        if (!root) { 
            cout << "AVL Level-wise Display:\n(Empty)" << endl; 
            return; 
        }

        queue<pair<AVLNode*, int>> q;
        q.push({root, 0});

        cout << "\nAVL Level-wise Display:" << endl;
        while (!q.empty()) {
            AVLNode* node = q.front().first;
            int level = q.front().second;
            q.pop();

            cout << "Level " << level << " : " << node->data.getID();
            
            // Show left child
            cout << "  L:";
            if (node->left) {
                cout << node->left->data.getID();
                q.push({node->left, level + 1});
            } else {
                cout << "NULL";
            }

            // Show right child
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

    // Load flight data (same format as BST save)
    void loadFromBSTData(string filename) {
        ifstream inFile(filename);
        if (!inFile) return;
        int id; string dest, dep, stat; float dur;
        while (inFile >> id >> dest >> dep >> dur >> stat) {
             if(TimeUtils::isValidTime(dep)) insert(Flight(id, dest, dep, dur, stat));
        }
        inFile.close();
    }
};

#endif
