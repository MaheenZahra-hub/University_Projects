
#ifndef STACK_H
#define STACK_H

#include "bst.h" 

// Node for the linked-list implementation of the stack
struct StackNode {
    Flight data;
    StackNode* next;
    StackNode(Flight f) : data(f), next(nullptr) {}
};

class FlightStack {
private:
    StackNode* top;

public:
    // Constructor initializes an empty stack
    FlightStack() : top(nullptr) {}

    // Push a flight onto the stack
    void push(Flight f) {
        StackNode* newNode = new StackNode(f);
        newNode->next = top;
        top = newNode;
    }

    // Check whether the stack is empty
    bool isEmpty() { return top == nullptr; }

    // Pop and return the top flight
    Flight pop() {
        if (isEmpty()) return Flight(-1, "", "", 0, "");
        StackNode* temp = top;
        Flight data = temp->data;
        top = top->next;
        delete temp;     //free memory
        return data;
    }
};

#endif