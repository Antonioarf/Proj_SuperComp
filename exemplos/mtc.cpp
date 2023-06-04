#include <iostream>
#include <omp.h>

// Binary tree node structure
struct Node {
    int key;
    Node* left;
    Node* right;
};

// Function to search for a key in a binary tree
bool searchBinaryTree(Node* node, int key) {
    // Base case: empty tree or key found at current node
    if (node == nullptr || node->key == key) {
        return (node != nullptr);
    }

    // Recursive case: search in left and right subtrees
    if (key < node->key) {
        return searchBinaryTree(node->left, key);
    } else {
        return searchBinaryTree(node->right, key);
    }
}

// Function to perform parallel search in binary tree
bool parallelSearchBinaryTree(Node* root, int key) {
    bool found = false;

    #pragma omp parallel for
    for (int i = 0; i < omp_get_num_threads(); i++) {
        if (!found) {
            int tid = omp_get_thread_num();
            int numThreads = omp_get_num_threads();
            int startIndex = i * (root->key / numThreads);
            int endIndex = (i + 1) * (root->key / numThreads) - 1;

            if (i == numThreads - 1) {
                endIndex = root->key - 1;
            }

            #pragma omp critical
            {
                if (!found) {
                    std::cout << "Thread " << tid << " searching from " << startIndex
                              << " to " << endIndex << std::endl;
                }
            }

            // Perform search in the assigned range
            for (int j = startIndex; j <= endIndex; j++) {
                if (searchBinaryTree(root, j)) {
                    found = true;

                    #pragma omp critical
                    {
                        std::cout << "Thread " << tid << " found the key: " << j << std::endl;
                    }

                    break;
                }
            }
        }
    }

    return found;
}

int main() {
    // Create a sample binary tree
    Node* root = new Node{8, nullptr, nullptr};
    root->left = new Node{4, nullptr, nullptr};
    root->right = new Node{12, nullptr, nullptr};
    root->left->left = new Node{2, nullptr, nullptr};
    root->left->right = new Node{6, nullptr, nullptr};
    root->right->left = new Node{10, nullptr, nullptr};
    root->right->right = new Node{14, nullptr, nullptr};

    // Key to search in the binary tree
    int keyToSearch = 6;

    // Perform parallel search in the binary tree
    bool found = parallelSearchBinaryTree(root, keyToSearch);

    if (found) {
        std::cout << "Key " << keyToSearch << " found in the binary tree." << std::endl;
    } else {
        std::cout << "Key " << keyToSearch << " not found in the binary tree." << std::endl;
    }

    // Clean up the allocated memory
    // ...
    
    return 0;
}