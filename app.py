import psycopg2
import networkx as nx
import matplotlib.pyplot as plt


class Bank:
    def __init__(self, host, database, user, password, port):
        self.conn = psycopg2.connect(
            host=host, database=database, user=user, password=password, port=port)
        self.cur = self.conn.cursor()

    def trace_transaction(self, id):
        graph = nx.DiGraph()
        edge_labels = dict()

        self.cur.execute(f"select * from trn_src_des where voucherid = '{id}'")
        tar = self.cur.fetchone()
        graph.add_nodes_from(
            [tar[4] or f'CASH_{tar[0]}', tar[5] or f'CASH_{tar[0]}'])

        self.cur.execute(
            f"select * from (select * from transact('{id}', 'r') union select * from transact('{id}', 'l')) as t order by trndate, trntime")

        for i in self.cur.fetchall():
            src_dest = (i[4] or f'CASH_{i[0]}', i[5] or f'CASH_{i[0]}')
            graph.add_nodes_from(src_dest)
            graph.add_edge(*src_dest)
            edge_labels[src_dest] = f'{i[3]}\n{i[1]}\n{i[2]}'

        pos = nx.planar_layout(graph)
        plt.figure()
        plt.axis('off')

        nx.draw_networkx_nodes(graph, pos, nodelist=graph.nodes(),
                               node_color='tab:red', edgecolors='tab:gray', node_size=600, alpha=1)
        nx.draw_networkx_edges(graph, pos, width=1, alpha=0.6)
        nx.draw_networkx_edges(
            graph, pos, edgelist=graph.edges(), width=5, alpha=0.5, edge_color="blue")
        nx.draw_networkx_labels(graph, pos, font_size=10, font_color='whitesmoke',
                                labels={node: node if 'CASH' not in str(node) else 'CA' for node in graph.nodes()})
        nx.draw_networkx_edge_labels(
            graph, pos, edge_labels=edge_labels, font_color='brown', font_size=7)
        plt.show()

    def get_invalid_customers(self):
        query = "select cid, name, natcod, \
                    (case \
 	                    when ctrl_bit < 2 then ctrl_bit = cast(substring(natcod, 10, 1) as int) \
 	                    else ctrl_bit = 11 - cast(substring(natcod, 10, 1) as int) \
                        end) as is_valid \
                    from check_national_code;"
        self.cur.execute(query)
        for i in self.cur.fetchall():
            if not i[3]:
                print(f'{i[0]}, {i[1]}, {i[2]}')

    def exec(self, query):
        self.cur.execute(query)
        return self.cur.fetchall()


bank = Bank(host='localhost',
            database='Bank',
            user='postgres',
            password='admin',
            port='5432')


while True:
    command = input().lower()
    if command.startswith('trace transaction'):
        bank.trace_transaction(int(command[(len('trace transaction') + 1):]))
    elif command == 'invalid customers':
        bank.get_invalid_customers()
    elif command == 'end':
        break
    else:
        for i in bank.exec(command):
            print(i)


# sample
# invalid customers
# trace transaction 5
# end
