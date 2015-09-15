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


class OpenMoveEvalFn():
    
    def score(self, game):
        return len(game.get_legal_moves())


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


class CustomPlayer():
	# ab_depth = 3
    def __init__(self, minimax_search_depth=3, eval_fn=CustomEvalFn()):
        self.eval_fn = eval_fn
        self.minimax_search_depth = minimax_search_depth
        self.alphabeta_search_depth = 4
        self.abort_time = 50
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
        # print 'best move determined', best_move, best_score, self.time_left()
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

        while (self.time_left() > 15 * self.alphabeta_search_depth or self.time_left() > (2 * self.abort_time)) and not(math.isinf(result_score)):
            result_score, result_move = self.alphabeta(game, 0)
            # print "returned result from iteration ", self.alphabeta_search_depth, result_score, result_move, self.time_left()
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

"""Test"""
from isolation import Board
if __name__ == "__main__":
    r = CustomPlayer()
    h = CustomPlayer()
    game = Board(h, r)
    game.play_isolation()

