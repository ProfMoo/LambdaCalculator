Our code successfully performs Eta Reduction, Beta Reduction, and Alpha Renaming.

Code Function:
It functions almost entirely through pattern matching. All lambda expressions that are sent in are checked against one of three
cases. Atom, lambda(V E), and (E E). The first operation that is performed is alpha renaming. This is all done at the beginning.
Then, from there, the lambda expression is sent back into a reducer function that
simplifies down to Atom level. As the code is recursing back up, beta reduction is done whenever possible. Once this is completed,
the lambda expression is sent into Eta reduction to completely finish it.

Bugs:
8/8 of the problems evaluate correctly. There are no errors that we see from all of our test cases.
