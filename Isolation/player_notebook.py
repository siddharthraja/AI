
# coding: utf-8

# This is the ipython notebook you should use as a template for your agent. Your task for this assignment is to implement a winning AI for the game of Isolation, as specified in the assignment pdf you have been issued.
# 
# The following random agent just selects a move out of the set of legal moves. Note that your agent, when asked for a move, is already provided with the set of moves available to it. This is done for your convenience. If your agent attempts to perform an illegal move, it will lose, so please refrain from doing so. It is also provided with a function that, when invoked, returns the amount of time left for your agent to make its move. If your agent fails to make a move in the alloted time, it will lose.
# 

# In[ ]:

from random import randint
import math

class RandomPlayer():
    """Player that chooses a move randomly."""
    def __init__(self):
        self.eval_fn = OpenMoveEvalFn()

    def move(self, game, legal_moves, time_left):
        #print time_left()
        #print self.eval_fn.score(game)
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
        return len(game.get_legal_moves())


#     The following is a 
#     Custom evaluation function that acts
#     however you think it should. This is not
#     required but highly encouraged if you
#     want to build the best AI possible.

# In[ ]:

class CustomEvalFn():

    def score(self, game):
        count_active = len(game.get_legal_moves())
        count_opp = len(game.get_opponent_moves())
        if count_opp == 0: count_opp = 1
        return int(float(count_active) / count_opp * 1000)

    def score_max(self, game, move):
        count_active = len(game.get_legal_moves())
        count_opp = len(game.get_opponent_moves())
        if count_opp == 0: count_opp = 1
        return int(float(count_active) / count_opp * 1000)

    def score_min(self, game, move):
        count_active = len(game.get_legal_moves())
        count_opp = len(game.get_opponent_moves())
        if count_active == 0: count_active = 1
        return int(float(count_opp) / count_active * 1000)

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
    # ab_depth = 3
    def __init__(self, minimax_search_depth=3, eval_fn=CustomEvalFn()):
        self.eval_fn = eval_fn
        self.minimax_search_depth = minimax_search_depth
        self.alphabeta_search_depth = 4
        self.abort_time = 40
        self.time_left = None
        self.legal_moves = None
        self.tree = None
        self.moves_done = 0

    def move(self, game, legal_moves, time_left):
        self.moves_done = self.moves_done + 1
        self.time_left = time_left
        self.legal_moves = legal_moves
        # best_score, best_move = self.minimax(game, 0)
        self.alphabeta_search_depth = 4
        # best_score, best_move = self.alphabeta(game, 0)
        best_score, best_move = self.alphabeta_iterative_deepening(game)
        print 'best move determined', best_move, best_score, self.time_left()
        return best_move


    def minimax(self, game, depth=float("inf"), maximizing_player=True):
        # Handle leaf node
        if depth == self.minimax_search_depth or self.time_left() < self.abort_time:
            return self.utility(game), (-1, -1)

        if depth == 0:
            legal_moves = self.legal_moves
        else:
            legal_moves = game.get_legal_moves()
        # Just in case 
        if len(legal_moves) == 0:
            return self.utility(game), (-1, -1)
        best_val = float("inf")
        if maximizing_player:
            best_val = float("-inf")

        best_move = (-1, -1)

        for m in legal_moves:
            res_score, res_move = self.minimax(game.forecast_move(m), depth+1, not maximizing_player)
            if maximizing_player:
                if res_score > best_val:
                    best_val = res_score
                    best_move = m
            else:
                if res_score < best_val:
                    best_val = res_score
                    best_move = m

        return best_val, best_move


    def alphabeta(self, game, depth=float("inf"), alpha=float("-inf"), beta=float("inf"), maximizing_player=True, causing_move=()):
        # Handle leaf node
        if depth == self.alphabeta_search_depth or self.time_left() < self.abort_time:
            return self.utility_alphabeta(game, causing_move, maximizing_player), causing_move

        if depth == 0:
            legal_moves = self.legal_moves
        else:
            legal_moves = game.get_legal_moves()

        # Just in case 
        if len(legal_moves) == 0:
            return self.utility_alphabeta(game, causing_move, maximizing_player), causing_move

        best_move = (-1, -1)
        for m in legal_moves:
            result, dummy = self.alphabeta(game.forecast_move(m), depth+1, alpha, beta, not maximizing_player)
            if maximizing_player:
                if result > alpha:
                    alpha = result
                    best_move = m
                if result >= beta:
                    break
            else:
                if result < beta:
                    beta = result
                    best_move = m
                if result <= alpha:
                    break
        if maximizing_player:
            return alpha, best_move
        else:
            return beta, best_move

    def alphabeta_iterative_deepening(self, game):
        # Handle leaf node
        if self.moves_done < 3: self.alphabeta_search_depth = 1
        else: self.alphabeta_search_depth = 1
        result_score = best_score = 0
        result_move = best_move = (-1, -1)

        while (self.time_left() > 10 * self.alphabeta_search_depth or self.time_left() > (2 * self.abort_time)) and not(math.isinf(result_score)):
            result_score, result_move = self.alphabeta(game, 0)
            print "returned result from interation ", self.alphabeta_search_depth, result_score, result_move, self.time_left()
            if result_score > best_score:
                best_score = result_score
                best_move = result_move
            self.alphabeta_search_depth = self.alphabeta_search_depth + 1
        return best_score, best_move


    def utility_alphabeta(self, game, causing_move, max_player):
        if game.is_winner(self):
            return float("inf")

        if game.is_opponent_winner(self):
            return float("-inf")

        if max_player:
            return self.eval_fn.score_max(game, causing_move)
        else:
            return self.eval_fn.score_min(game, causing_move)

    def utility(self, game):
        if game.is_winner(self):
            return float("inf")

        if game.is_opponent_winner(self):
            return float("-inf")

        return self.eval_fn.score(game)
# The following are some basic tests you can use to sanity-check your code. You will also be provided with a test server to which you will be able to submit your agents later this week. Good luck!

# In[ ]:

"""Example test you can run
to make sure your AI does better
than random."""
from isolation import Board
if __name__ == "__main__":
    r = CustomPlayer()
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
    print('This board has"""