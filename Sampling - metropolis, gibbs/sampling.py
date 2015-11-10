import sys
# from importlib import reload
if('pbnt/combined' not in sys.path):
    sys.path.append('pbnt/combined')
from exampleinference import inferenceExample


from random import randint
import numpy as np
from Node import BayesNode
from Graph import BayesNet
from numpy import zeros, float32
import Distribution
from Distribution import DiscreteDistribution, ConditionalDiscreteDistribution


# Example Problem
# 
# There are three frisbee teams who play each other: the Airheads, the Buffoons, and the Clods (A, B and C for short). Each match is between two teams, and each team can either win, lose, or draw in a match. Each team has a fixed but unknown skill level, represented as an integer from 0 to 3. Each match's outcome is probabilistically proportional to the difference in skill level between the teams.
# Problem involves predicting the outcome of the matches, given prior knowledge of previous matches. Rather than using inference, sampling the network will be used which involve Markov Chain Monte Carlo models: Metropolis-Hastings (2b) and Gibbs sampling (2c).
# 
# Build a Bayes Net to represent the three teams and their influences on the match outcomes. Variable conventions:
# 
# | variable name | description|
# |---------|:------:|
# |A| A's skill level|
# |B | B's skill level|
# |C | C's skill level|
# |AvB | the outcome of A vs. B <br> (0 = A wins, 1 = B wins, 2 = tie)|
# |BvC | the outcome of B vs. C <br> (0 = B wins, 1 = C wins, 2 = tie)|
# |CvA | the outcome of C vs. A <br> (0 = C wins, 1 = A wins, 2 = tie)|
# 
# Assume that each team has the following prior distribution of skill levels:
# 
# |skill level|P(skill level)|
# |----|:----:|
# |0|0.15|
# |1|0.45|
# |2|0.30|
# |3|0.10|
# 
# In addition, assume that the differences in skill levels correspond to the following probabilities of winning:
# 
# | skill difference <br> (T2 - T1) | T1 wins | T2 wins| Tie |
# |------------|----------|---|:--------:|
# |0|0.10|0.10|0.80|
# |1|0.20|0.60|0.20|
# |2|0.15|0.75|0.10|
# |3|0.05|0.90|0.05|


def get_game_network():
    """A Bayes Net representation
    of the game problem."""
    nodes = []
    # TODO: fill this out
    A_node = BayesNode(0, 4, name='A')
    B_node = BayesNode(1, 4, name='B')
    C_node = BayesNode(2, 4, name='C')
    AvB_node = BayesNode(3, 3, name='A vs B')
    BvC_node = BayesNode(4, 3, name='B vs C')
    CvA_node = BayesNode(5, 3, name='C vs A')
    nodes = []
    
    A_node.add_child(AvB_node)
    AvB_node.add_parent(A_node)
    B_node.add_child(AvB_node)
    AvB_node.add_parent(B_node)
    
    B_node.add_child(BvC_node)
    BvC_node.add_parent(B_node)
    C_node.add_child(BvC_node)
    BvC_node.add_parent(C_node)
    
    C_node.add_child(CvA_node)
    CvA_node.add_parent(C_node)
    A_node.add_child(CvA_node)
    CvA_node.add_parent(A_node)
    
    nodes.append(A_node)
    nodes.append(B_node)
    nodes.append(C_node)
    nodes.append(AvB_node)    
    nodes.append(BvC_node)
    nodes.append(CvA_node)

    A_distribution = DiscreteDistribution(A_node)
    index = A_distribution.generate_index([],[])
    A_distribution[index] = [0.15,0.45,0.3,0.1]
    A_node.set_dist(A_distribution)
    
    B_distribution = DiscreteDistribution(B_node)
    index = B_distribution.generate_index([],[])
    B_distribution[index] = [0.15,0.45,0.3,0.1]
    B_node.set_dist(B_distribution)
   
    C_distribution = DiscreteDistribution(C_node)
    index = C_distribution.generate_index([],[])
    C_distribution[index] = [0.15,0.45,0.3,0.1]
    C_node.set_dist(C_distribution)
    
    dist = zeros([A_node.size(), B_node.size(), AvB_node.size()], dtype=float32)
    # T2-T1=0
    dist[0,0,:] = [0.10,0.10,0.80]
    dist[1,1,:] = [0.10,0.10,0.80]
    dist[2,2,:] = [0.10,0.10,0.80]
    dist[3,3,:] = [0.10,0.10,0.80]
    # T2-T1=1
    dist[0,1,:] = [0.20,0.60,0.20]
    dist[1,2,:] = [0.20,0.60,0.20]
    dist[2,3,:] = [0.20,0.60,0.20]
    dist[1,0,:] = [0.60,0.20,0.20]
    dist[2,1,:] = [0.60,0.20,0.20]
    dist[3,2,:] = [0.60,0.20,0.20]
    # T2-T1=2
    dist[0,2,:] = [0.15,0.75,0.10]
    dist[1,3,:] = [0.15,0.75,0.10]
    dist[2,0,:] = [0.75,0.15,0.10]
    dist[3,1,:] = [0.75,0.15,0.10]
    # T2-T1=3
    dist[0,3,:] = [0.05,0.90,0.05]
    dist[3,0,:] = [0.90,0.05,0.05]
    
    AvB_distribution = ConditionalDiscreteDistribution(nodes=[A_node, B_node, AvB_node], table=dist)
    AvB_node.set_dist(AvB_distribution)
    
    # P(BvC|B,C)
    dist = zeros([B_node.size(), C_node.size(), BvC_node.size()], dtype=float32)
    # T2-T1=0
    dist[0,0,:] = [0.10,0.10,0.80]
    dist[1,1,:] = [0.10,0.10,0.80]
    dist[2,2,:] = [0.10,0.10,0.80]
    dist[3,3,:] = [0.10,0.10,0.80]
    # T2-T1=1
    dist[0,1,:] = [0.20,0.60,0.20]
    dist[1,2,:] = [0.20,0.60,0.20]
    dist[2,3,:] = [0.20,0.60,0.20]
    dist[1,0,:] = [0.60,0.20,0.20]
    dist[2,1,:] = [0.60,0.20,0.20]
    dist[3,2,:] = [0.60,0.20,0.20]
    # T2-T1=2
    dist[0,2,:] = [0.15,0.75,0.10]
    dist[1,3,:] = [0.15,0.75,0.10]
    dist[2,0,:] = [0.75,0.15,0.10]
    dist[3,1,:] = [0.75,0.15,0.10]
    # T2-T1=3
    dist[0,3,:] = [0.05,0.90,0.05]
    dist[3,0,:] = [0.90,0.05,0.05]
    
    BvC_distribution = ConditionalDiscreteDistribution(nodes=[B_node, C_node, BvC_node], table=dist)
    BvC_node.set_dist(BvC_distribution)
    
    # P(CvA|C,A)
    dist = zeros([C_node.size(), A_node.size(), CvA_node.size()], dtype=float32)
    # T2-T1=0
    dist[0,0,:] = [0.10,0.10,0.80]
    dist[1,1,:] = [0.10,0.10,0.80]
    dist[2,2,:] = [0.10,0.10,0.80]
    dist[3,3,:] = [0.10,0.10,0.80]
    # T2-T1=1
    dist[0,1,:] = [0.20,0.60,0.20]
    dist[1,2,:] = [0.20,0.60,0.20]
    dist[2,3,:] = [0.20,0.60,0.20]
    dist[1,0,:] = [0.60,0.20,0.20]
    dist[2,1,:] = [0.60,0.20,0.20]
    dist[3,2,:] = [0.60,0.20,0.20]
    # T2-T1=2
    dist[0,2,:] = [0.15,0.75,0.10]
    dist[1,3,:] = [0.15,0.75,0.10]
    dist[2,0,:] = [0.75,0.15,0.10]
    dist[3,1,:] = [0.75,0.15,0.10]
    # T2-T1=3
    dist[0,3,:] = [0.05,0.90,0.05]
    dist[3,0,:] = [0.90,0.05,0.05]
    
    CvA_distribution = ConditionalDiscreteDistribution(nodes=[C_node, A_node, CvA_node], table=dist)
    CvA_node.set_dist(CvA_distribution)
   
    return BayesNet(nodes)


# Metropolis-Hastings sampling


def get_prob(bayes_net, val):
    A = bayes_net.get_node_by_name('A')
    B = bayes_net.get_node_by_name('B')
    C = bayes_net.get_node_by_name('C')
    AB = bayes_net.get_node_by_name('A vs B')
    BC = bayes_net.get_node_by_name('B vs C')
    CA = bayes_net.get_node_by_name('C vs A')
    
    tab = [A.dist.table, B.dist.table, C.dist.table] #AB.dist.table, BC.dist.table, CA.dist.table]
    p1 = (tab[0][val[0]]) * (tab[1][val[1]]) * (tab[2][val[2]])
    pab = AB.dist.table[val[1]][val[0]]
    pbc = BC.dist.table[val[2]][val[1]]
    pca = CA.dist.table[val[0]][val[2]]
    probability = p1 * (pab[val[3]]) * (pbc[val[4]]) * (pca[val[5]]) 
    
    return probability


def MH_sampling(bayes_net, initial_value):
    """A single iteration of the 
    Metropolis-Hastings algorithm given a
    Bayesian network and an initial state
    value. Returns the state sampled from
    the probability distribution."""
    # TODO: finish this function
    # AvB(3) => 1-0
    # BvC(4) => 2-1
    # CvA(5) => 0-2
    # curr_tuple = initial_value # [A,B,C, AvB,BvC,CvA]
    nodes = list(bayes_net.nodes)
    rand_node = randint(0,5)    
    current = nodes[rand_node]
    prob_dist = current.dist.table
    sample = []
    sample.append(initial_value[0])
    sample.append(initial_value[1])
    sample.append(initial_value[2])
    sample.append(initial_value[3])
    sample.append(initial_value[4])
    sample.append(initial_value[5])
    
    if rand_node < 3:
        r = randint(0,3)
        #print alpha
    else:
        r = randint(0,2)
        
    sample[rand_node] = r    

    numerator = get_prob(bayes_net, sample)
    den = get_prob(bayes_net, initial_value)
    alpha = (numerator) / (den)
    
    #print alpha, numerator, den, sample
    alpha = min([1, alpha])
    x=np.random.uniform(0,1,1)
    
    if x>=alpha:
        #print 'not accepted'
        sample = initial_value

    #print alpha, sample
    return sample


# Gibbs sampling

def Gibbs_sampling(bayes_net, initial_value):
    """A single iteration of the
    Gibbs sampling algorithm given a
    Bayesian network and an initial state
    value. Returns the state sampled from
    the probability distribution."""
    
    nodes = list(bayes_net.nodes)
    rand_node = randint(0,5)    
    current = nodes[rand_node]
    prob_dist = current.dist.table
    sample = []
    sample.append(initial_value[0])
    sample.append(initial_value[1])
    sample.append(initial_value[2])
    sample.append(initial_value[3])
    sample.append(initial_value[4])
    sample.append(initial_value[5])
    temp = sample
    if rand_node < 3:
        #r = randint(0,3)
        temp[rand_node] = 0
        n0 = get_prob(bayes_net, temp)
        temp[rand_node] = 1
        n1 = get_prob(bayes_net, temp)
        temp[rand_node] = 2
        n2 = get_prob(bayes_net, temp)
        temp[rand_node] = 3
        n3 = get_prob(bayes_net, temp)
        d = n0+n1+n2+n3
        l = [n0/d, n1/d, n2/d, n3/d]
        l1 = [l[0], l[0]+l[1], l[0]+l[1]+l[2], l[0]+l[1]+l[2]+l[3]]
        #pdf = {n0/d:0, n1/d:1, n2/d:2, n3/d:3} #{0:n0/d, 1:n1/d, 2:n2/d, 3:n3/d}
        x=np.random.uniform(0,1,1)
        for i in range(0, len(l1)):
            if(x<=l1[i]): break;
        final_val = i
        initial_value[rand_node] = final_val

    else:
        #r = randint(0,2)
        temp[rand_node] = 0
        n0 = get_prob(bayes_net, temp)
        temp[rand_node] = 1
        n1 = get_prob(bayes_net, temp)
        temp[rand_node] = 2
        n2 = get_prob(bayes_net, temp)
        d = n0+n1+n2
        l = [n0/d, n1/d, n2/d]
        l1 = [l[0], l[0]+l[1], l[0]+l[1]+l[2]]
        #pdf = {n0/d:0, n1/d:1, n2/d:2} #{0:n0/d, 1:n1/d, 2:n2/d}
        x=np.random.uniform(0,1,1)
        for i in range(0, len(l1)):
            if(x<=l1[i]): break;
        final_val = i
        initial_value[rand_node] = final_val        
    
    #print rand_node
    #print final_val, initial_value
    
    return initial_value


# Comparing sampling methods


def are_tuples_same(a, b):
    if len(a) != len(b):
        return False
    flag = True
    for i in range(0, len(a)):
        if a[i]!=b[i]:
            flag = False
    return flag


def calculate_posterior(games_net):
    """Example: Calculating the posterior distribution
    of the BvC match given that A won against
    B and tied C. Return a list of probabilities
    corresponding to win, loss and tie likelihood."""
    posterior = [0,0,0]
    
    AB = games_net.get_node_by_name('A vs B')
    BC = games_net.get_node_by_name('B vs C')
    CA = games_net.get_node_by_name('C vs A')
    
    engine =  JunctionTreeEngine(games_net)
    engine.evidence[AB] = 0
    engine.evidence[CA] = 2
    Q = engine.marginal(BC)[0]
    index = Q.generate_index([0],range(Q.nDims))
    posterior[0] = Q[index]
    
    engine =  JunctionTreeEngine(games_net)
    engine.evidence[AB] = 0
    engine.evidence[CA] = 2
    Q = engine.marginal(BC)[0]
    index = Q.generate_index([1],range(Q.nDims))
    posterior[1] = Q[index]
    
    engine =  JunctionTreeEngine(games_net)
    engine.evidence[AB] = 0
    engine.evidence[CA] = 2
    Q = engine.marginal(BC)[0]
    index = Q.generate_index([2],range(Q.nDims))
    posterior[2] = Q[index]
    
    return posterior


iter_counts = [1e1,1e3,1e5,1e6]
def compare_sampling_initial(bayes_net, posterior):
    """Compare Gibbs and Metropolis-Hastings
    sampling by calculating how long it takes
    for each method to converge to the 
    provided posterior."""
    
    # Metropolis
    prob = [0,0,0,0,0, 0,0,0,0,0]
    count = iterations = 0
    converges = False
    tuple_list = [[],[],[],[],[],[],[],[],[],[]]
    initial_value = [0,0,0,0,0,2]
    curr_sample = []
    for i in range(0, len(initial_value)):
        curr_sample.append(initial_value[i])
    print curr_sample
    while not converges and count < 150000:
        iterations = iterations + 1
        temp = MH_sampling(game_net, curr_sample)
        if not are_tuples_same(temp, curr_sample):
            curr_sample = temp
            prob[count%10] = get_prob(bayes_net, curr_sample)
            tuple_list[count%10] = curr_sample
            count = count + 1
            if count >10:
                #convg = np.std(posterior)
                converges = True
                for i in range(1,10):
                    if (float(abs(prob[i] - prob[i-1]))/prob[i-1]) > 0.0009:
                        converges = False
                if converges:
                    print 'converging'
    MH_convergence = np.mean(prob)        
    print '\n', count, iterations, '\n', tuple_list, '\n', prob, MH_convergence
    
    Gibbs_convergence = 0.0
    return Gibbs_convergence, MH_convergence


iter_counts = [1e1,1e3,1e5,1e6]
def compare_sampling(bayes_net, posterior):
    """Comparing Gibbs and Metropolis-Hastings
    sampling by calculating how long it takes
    for each method to converge to the 
    provided posterior."""
    # Metropolis
    
    count = 0
    convg = 0
    initial_value = [0,0,0,0,0,2]
    prob = [0,0,0]
    new = [0,0,0]
    old = [0,0,0]
    iteration = 0
    curr_sample = []
    for i in range(0, len(initial_value)):
        curr_sample.append(initial_value[i])
        
    while convg <= 10 and iteration <= 250000:
        temp = MH_sampling(bayes_net, curr_sample)
        iteration = iteration + 1
        if temp[3]!=0 or temp[5]!=2: 
            continue
        # 
        curr_sample = temp
        if count < 1000:
            count = count + 1
            prob[temp[4]] = prob[temp[4]] + 1
        else:         
            old = [float(prob[0])/count, float(prob[1])/count, float(prob[2])/count]
            count =  count + 1
            prob[temp[4]] = prob[temp[4]] + 1
            new = [float(prob[0])/count, float(prob[1])/count, float(prob[2])/count]
            if new[0] == 0 or new[1] == 0 or new[2] == 0:
                print new, count
            x = abs(old[0]-new[0])/float(new[0]) * 100
            y = abs(old[1]-new[1])/float(new[1]) * 100
            z = abs(old[2]-new[2])/float(new[2]) * 100
            #print new
            if x<0.10 and y<0.10 and z<0.10:
                convg = convg + 1
            else:
                convg = 0

    MH_convergence = count #[float(prob[0])/count, float(prob[1])/count, float(prob[2])/count]
    #print 'MH_convergence', MH_convergence, count, iteration
    #------------------------------------------------------------------------------------
    Gibbs_convergence = gibbs_samp(bayes_net)
    return Gibbs_convergence, MH_convergence


def gibbs_samp(bayes_net):
    burn = 1000
    count = 0
    convg = 0
    initial_value = [0,0,0,0,0,2]
    prob = [0,0,0]
    new = [0,0,0]
    old = [0,0,0]
    iteration = 0
    curr_sample = []
    for i in range(0, len(initial_value)):
        curr_sample.append(initial_value[i])
        
    while convg <= 10 and iteration <= 250000:
        temp = Gibbs_sampling(bayes_net, curr_sample)
        iteration = iteration + 1
        if temp[3]!=0 or temp[5]!=2: 
            continue
        # 
        curr_sample = temp
        if count < burn:
            count = count + 1
            prob[temp[4]] = prob[temp[4]] + 1
        else:         
            old = [float(prob[0])/count, float(prob[1])/count, float(prob[2])/count]
            count =  count + 1
            prob[temp[4]] = prob[temp[4]] + 1
            new = [float(prob[0])/count, float(prob[1])/count, float(prob[2])/count]
            if new[0] == 0 or new[1] == 0 or new[2] == 0:
                print new, count
            x = abs(old[0]-new[0])/float(new[0]) * 100
            y = abs(old[1]-new[1])/float(new[1]) * 100
            z = abs(old[2]-new[2])/float(new[2]) * 100
            #print new
            if x<0.10 and y<0.10 and z<0.10:
                convg = convg + 1
            else:
                convg = 0

    Gibbs_convergence = count #[float(prob[0])/count, float(prob[1])/count, float(prob[2])/count]
    #print 'Gibbs_convergence', Gibbs_convergence, count, iteration
    return Gibbs_convergence



if __name__ == "__main__":
    
    game_net = get_game_network()
    # arbitrary initial state for the game system
    initial_value = [0,0,0,0,0,0] 
    # print get_prob(game_net, [0,0,0,2,0,0])
    sample = MH_sampling(game_net, initial_value)
    print 'MH', sample

    initial_value = [0,0,2,0,0,1]
    sample = Gibbs_sampling(game_net, initial_value)
    print 'Gibbs', sample

    posterior = calculate_posterior(game_net)
    Gibbs_convergence, MH_convergence = compare_sampling(game_net, posterior)
    print Gibbs_convergence, MH_convergence