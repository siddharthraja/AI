
# coding: utf-8

# This is the ipython notebook you should use as a template for your agent. Your task for this assignment is to implement a winning AI for the game of Isolation, as specified in the assignment pdf you have been issued.
# 
# The following random agent just selects a move out of the set of legal moves. Note that your agent, when asked for a move, is already provided with the set of moves available to it. This is done for your convenience. If your agent attempts to perform an illegal move, it will lose, so please refrain from doing so. It is also provided with a function that, when invoked, returns the amount of time left for your agent to make its move. If your agent fails to make a move in the alloted time, it will lose.
# 

# In[ ]:

from random import randint
import Queue

class RandomPlayer():
    """Player that chooses a move randomly."""
    def __init__(self):
        self.eval_fn = OpenMoveEvalFn()

    def move(self, game, legal_moves, time_left):
        print time_left()
        print self.eval_fn.score(game)
        if not legal_moves: return (-1,-1)
        return legal_moves[randint(0,len(legal_moves)-1)]


# The following are functions that might be useful to you in developing your agent:
# 
#     game.get_legal_moves(): Returns a list of legal moves for the active player.
# 
#     game.get_opponent_moves(): Returns a list of legal moves for the inactive player.
# 
#     game.forecast_move(move): This returns a new board, whose state is the result of making the move specified on the current board.
# 
#     game.get_state(): This returns a 2D array containing a copy of the explicit state of the board. 
#     
#     game.is_winner(player): Returns whether your player agent has won.
#     
#     game.is_opponent_winner(player): Returns whether your player's opponent has won.    
#     
#     game.print_board(): Returns a string representation of the game board. This should be useful for debugging.
# 
# 

# In[ ]:

class HumanPlayer():
    """Player that chooses a move according to
    user's input."""
    def move(self, game, legal_moves, time_left):
        print('\t'.join(['[%d] %s'%(i,str(move)) for i,move in enumerate(legal_moves)] ))
        
        valid_choice = False
        while not valid_choice:
            try:
                index = int(raw_input('Select move index:'))
                valid_choice = 0 <= index < len(legal_moves)

                if not valid_choice:
                    print('Illegal move! Try again.')
            
            except ValueError:
                print('Invalid index! Try again.')
        return legal_moves[index]


# This is the first part of the assignment you are expected to implement. It is the evaluation function we've been using in class. The score of a specified game state is just the number of moves open to the active player.

# In[1]:

class OpenMoveEvalFn():
    
    def score(self, game):
        return len(game.get_legal_moves())#eval_func


#     The following is a 
#     Custom evaluation function that acts
#     however you think it should. This is not
#     required but highly encouraged if you
#     want to build the best AI possible.

# In[ ]:

class CustomEvalFn():

    def score(self, game):
        return len(game.get_legal_moves())


# Implement a Player below that chooses a move using 
#     your evaluation function and 
#     a depth-limited minimax algorithm 
#     with alpha-beta pruning.
#     You must finish and test this player
#     to make sure it properly uses minimax
#     and alpha-beta to return a good move
#     in less than 500 milliseconds.

# In[ ]:

class CustomPlayer():
    # TODO: finish this class!
    def __init__(self, search_depth=3, eval_fn=OpenMoveEvalFn()):
        self.eval_fn = eval_fn
        self.search_depth = search_depth
        self.legal_moves = []
        self.time_left = None
        self.tree = None

    """def move(self, game, legal_moves, time_left):
        self.legal_moves = legal_moves
        move_scores = []
        for m in self.legal_moves:
            move_scores.append(self.utility(game.forecast_move(m)))
        best_move = self.legal_moves[move_scores.index(max(move_scores))]
        # best_move, utility = self.minimax(game, depth=self.search_depth)
        # you will eventually replace minimax with alpha-beta
        print 'best move determined', best_move, max(move_scores)
        return best_move"""

    def move(self, game, legal_moves, time_left):
        self.time_left = time_left
        self.legal_moves = legal_moves
        self.tree = self.GameTree(self.Node(game, None, 0))
        self.generate_tree(3)
        best_move, best_val = self.minimax(game, 3)
        return best_move

    def utility(self, game):
        
        if game.is_winner(self):
            return float("inf")

        if game.is_opponent_winner(self):
            return float("-inf")

        return self.eval_fn.score(game)

    def generate_tree(self, depth):
        q = Queue.Queue()
        q.put(self.tree.root)
        above_depth = True
        # Generate Game Tree from depth 2. Depth 1 done.
        while not q.empty() and above_depth:
            curr_node = q.get()
            if curr_node.depth >= depth:
                above_depth = False
                continue
            if curr_node == self.tree.root:
                l_moves = self.legal_moves
            else:
                l_moves = curr_node.game.get_legal_moves()
            for m in l_moves:
                node = self.Node(curr_node.game.forecast_move(m), m, curr_node.depth + 1)
                curr_node.next.append(node)
                q.put(node)
        print "tree generated", self.time_left()

    def minimax(self, game, depth=float("inf"), maximizing_player=True):
        # stack = Queue.LifoQueue()
        # Tree traversal for static evaluations and deciding best move
        best_move = self.minimax_traversal(self.tree.root)
        best_val = 0
        return best_move, best_val

    def alphabeta(game, depth=float("inf"), alpha=float("-inf"), beta=float("inf"), maximizing_player=True):
        # TODO: finish this function!
        return best_move, best_val

    def minimax_traversal(self, curr_node):
        best_score_yet = best_move_yet = None
        if len(curr_node.next) == 0:
            best_score_yet = self.utility(curr_node.game)
            best_move_yet = curr_node.causing_move
            return [best_score_yet, best_move_yet]

        collect_moves = []
        collect_scores = []
        for nn in curr_node.next:
            if self.time_left() < 20: break
            result = self.minimax_traversal(nn)
            collect_scores.append(result[0])
            collect_moves.append(result[1])

        if len(collect_scores) > 0:
            ind = 0
            if curr_node.depth % 2 == 0:
                ind = collect_scores.index(max(collect_scores))
            else:
                ind = collect_scores.index(min(collect_scores))
            best_score_yet = collect_scores[ind]
            best_move_yet = collect_moves[ind]
        else:
            best_score_yet = self.utility(curr_node.next[0].game)
            best_move_yet = curr_node.next[0].causing_move
        return [best_score_yet, best_move_yet]


    class Node():
        def __init__(self, game, c_m, depth):
            self.next = []
            self.game = game
            self.causing_move = c_m
            self.depth = depth
            self.score = 0

    class GameTree():
        def __init__(self, root):
            self.root = root

# The following are some basic tests you can use to sanity-check your code. You will also be provided with a test server to which you will be able to submit your agents later this week. Good luck!

# In[ ]:

"""Example test you can run
to make sure your AI does better
than random."""
from isolation import Board
if __name__ == "__main__":
    r = RandomPlayer()
    h = CustomPlayer()
    game = Board(h, r)
    game.play_isolation()


# In[ ]:

"""Example test you can run
to make sure your basic evaluation
function works.
from isolation import Board

if __name__ == "__main__":
    sample_board = Board(RandomPlayer(),RandomPlayer())
    # setting up the board as though we've been playing
    sample_board.move_count = 3
    sample_board.__active_player__ = 0 # player 1 = 0, player 2 = 1
    # 1st board = 16 moves
    sample_board.__board_state__ = [
                [0,2,0,0,0],
                [0,0,0,0,0],
                [0,0,1,0,0],
                [0,0,0,0,0],
                [0,0,0,0,0]]
    sample_board.__last_player_move__ = [(2,2),(0,1)]

    # player 1 should have 16 moves available,
    # so board gets a score of 16
    h = OpenMoveEvalFn()
    print('This board has a score of %s.'%(h.score(sample_board)))
"""
